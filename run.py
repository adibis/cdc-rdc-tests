#!/usr/bin/env python3
"""Run every case manifest against an icarium binary and diff to oracle.

Each case owns its verdicts: elaborate, check, then match findings by
rule id plus one locator (source line, or destination name for port
findings). Extras fail unless the manifest allows them, so a seed can
only pass by reporting exactly what its author intended.
Usage: run.py --icarium-bin PATH [--tier N] [--case ID] [--ignore-notes]

Exit codes: 0 all pass, 1 verdict failures, 2 usage/environment error
(includes empty selection: a filter matching nothing is loud, never
green).
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC_LINE = re.compile(r":(\d+)[.-]")
TOP_OK = re.compile(r"[A-Za-z0-9_$.]+")
SEVERITIES = ("error", "warning", "note")


def src_line(src):
    m = SRC_LINE.search(src or "")
    return int(m.group(1)) if m else None


def elaborate(sv, top, out):
    if TOP_OK.fullmatch(top) is None:
        return f"invalid top {top!r}"
    cmd = ["yosys", "-p",
           f"read_verilog -sv \"{sv}\"; hierarchy -check -top {top}; "
           f"proc; flatten; write_json \"{out}\""]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        lines = r.stderr.strip().splitlines() or ["failed"]
        return f"yosys: {lines[-1]}"
    return None


def check(icarium, net, sdc, top, args):
    cmd = [str(icarium), "check", "--yosys-json", str(net),
           "--top", top, "--sdc", str(sdc), "--format", "json"] + args
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode not in (0, 1):
        return f"check exit {r.returncode}: {r.stderr.strip()[:200]}"
    try:
        got = json.loads(r.stdout or r.stderr)
    except json.JSONDecodeError as e:
        return f"bad json: {e}"
    if not isinstance(got, dict) or not isinstance(got.get("groups"), list):
        return "malformed checker output: want {groups: [...]}"
    for g in got["groups"]:
        if not isinstance(g, dict) or "rule" not in g or \
           not isinstance(g.get("items"), list):
            return "malformed checker output: group wants rule + items[]"
        for it in g["items"]:
            if not isinstance(it, dict) or \
               not isinstance(it.get("dst"), (dict, type(None))):
                return "malformed checker output: item wants dst object"
    return got


def validate_manifest(m):
    """Stdlib shape check mirroring schema/manifest.json."""
    if not isinstance(m, dict):
        return "manifest must be an object"
    known = {"id", "tier", "design", "top", "sdc", "expect",
             "allow_extra", "params", "notes"}
    if set(m) - known:
        return f"manifest unknown keys {sorted(set(m) - known)}"
    for k in ("id", "tier", "design", "top", "sdc", "expect"):
        if k not in m:
            return f"manifest missing {k!r}"
    if not isinstance(m["tier"], int) or m["tier"] not in (1, 2, 3):
        return "manifest tier must be 1, 2, or 3"
    if not isinstance(m["expect"], list):
        return "manifest expect must be a list"
    for e in m["expect"]:
        if not isinstance(e, dict):
            return "manifest expect entries must be objects"
        if set(e) - {"rule", "line", "dst", "severity"}:
            return f"manifest expect unknown keys {sorted(set(e) - {'rule', 'line', 'dst', 'severity'})}"
        if "rule" not in e:
            return "manifest expect entry without rule"
        if ("line" in e) == ("dst" in e):
            return "manifest expect wants exactly one of line/dst"
        if "line" in e and (not isinstance(e["line"], int) or e["line"] < 1):
            return "manifest expect line must be >= 1"
        if "dst" in e and (not isinstance(e["dst"], str) or not e["dst"]):
            return "manifest expect dst must be a non-empty string"
        if "severity" in e and e["severity"] not in SEVERITIES:
            return f"manifest severity must be one of {SEVERITIES}"
    if "allow_extra" in m and not isinstance(m["allow_extra"], bool):
        return "manifest allow_extra must be a boolean"
    if "params" in m:
        p = m["params"]
        if not isinstance(p, dict) or set(p) - {"sync_depth"}:
            return "manifest params allows only {sync_depth: int}"
        if "sync_depth" in p and \
           (not isinstance(p["sync_depth"], int) or p["sync_depth"] < 1):
            return "manifest sync_depth must be >= 1"
    return None


def read_manifest(path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError, UnicodeDecodeError) as e:
        return e


def params_to_args(m):
    if "params" in m and "sync_depth" in m["params"]:
        return ["--sync-depth", str(m["params"]["sync_depth"])]
    return []


def run_case(icarium, manifest, ignore_notes):
    m = read_manifest(manifest)
    if not isinstance(m, dict):
        return manifest.parent.name, [f"bad manifest: {m}"]
    bad = validate_manifest(m)
    if bad:
        return m.get("id", manifest.parent.name), [bad]
    cdir = manifest.parent
    with tempfile.TemporaryDirectory() as tmp:
        net = Path(tmp) / "net.json"
        err = elaborate(cdir / m["design"], m["top"], net)
        if err:
            return m["id"], [err]
        got = check(icarium, net, cdir / m["sdc"], m["top"],
                    params_to_args(m))
        if isinstance(got, str):
            return m["id"], [got]
    findings = []
    for g in got["groups"]:
        for it in g.get("items", []):
            if ignore_notes and it.get("severity") == "note":
                continue
            dst = it.get("dst") or {}
            findings.append((g["rule"], src_line(dst.get("src")),
                             dst.get("name") or "", dst.get("kind") or ""))
    errors = []
    unmatched = list(findings)
    for e in m["expect"]:
        if ignore_notes and e.get("severity", "error") == "note":
            continue
        hit = None
        for f in unmatched:
            if f[0] != e["rule"]:
                continue
            if "line" in e and f[1] != e["line"]:
                continue
            if "dst" in e and (f[3] != "port" or e["dst"] not in f[2]):
                continue
            hit = f
            break
        if hit is not None:
            unmatched.remove(hit)
        else:
            errors.append(f"missing {e}; got {[(f[0], f[1], f[2]) for f in findings]}")
    if unmatched and not m.get("allow_extra", False):
        errors.append(f"extra findings {unmatched}")
    return m["id"], errors


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--icarium-bin", required=True)
    ap.add_argument("--tier", type=int, default=None)
    ap.add_argument("--case", default=None)
    ap.add_argument("--ignore-notes", action="store_true")
    args = ap.parse_args()
    if shutil.which("yosys") is None:
        print("run.py: yosys not on PATH", file=sys.stderr)
        sys.exit(2)
    if not os.access(args.icarium_bin, os.X_OK):
        print(f"run.py: not executable {args.icarium_bin}", file=sys.stderr)
        sys.exit(2)
    manifests = sorted((ROOT / "cases").rglob("manifest.json"))
    selected = []
    for mf in manifests:
        m = read_manifest(mf)
        if not isinstance(m, dict):
            if args.case is not None and mf.parent.name != args.case:
                continue
            selected.append(mf)
            continue
        if args.tier is not None and m.get("tier") != args.tier:
            continue
        if args.case is not None and m.get("id") != args.case:
            continue
        selected.append(mf)
    if not selected:
        print("run.py: selection matched no cases", file=sys.stderr)
        sys.exit(2)
    fails = 0
    for mf in selected:
        cid, errs = run_case(Path(args.icarium_bin), mf, args.ignore_notes)
        if errs:
            fails += 1
            print(f"FAIL {cid}")
            for e in errs:
                print(f"    {e}")
        else:
            print(f"PASS {cid}")
    print(f"{len(selected) - fails} pass, {fails} fail", file=sys.stderr)
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
