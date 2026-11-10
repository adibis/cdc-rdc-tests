#!/usr/bin/env python3
"""Run every case manifest against an icarium binary and diff to oracle.

Each case owns its verdicts: elaborate, check, then match findings by
(rule, source line). Extras fail unless the manifest allows them, so a
seed can only pass by reporting exactly what its author intended.
Usage: run.py --icarium-bin PATH [--tier N] [--case ID]
"""
import argparse
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC_LINE = re.compile(r":(\d+)[.-]")


def src_line(src):
    m = SRC_LINE.search(src or "")
    return int(m.group(1)) if m else None


def elaborate(sv, top, out):
    cmd = ["yosys", "-p",
           f"read_verilog -sv {sv}; hierarchy -check -top {top}; "
           f"proc; flatten; write_json {out}"]
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        return f"yosys: {r.stderr.strip().splitlines()[-1] if r.stderr else 'failed'}"
    return None


def check(icarium, net, sdc, top, args, out):
    cmd = [str(icarium), "check", "--yosys-json", str(net),
           "--top", top, "--sdc", str(sdc), "--format", "json"] + args
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode not in (0, 1):
        return f"check exit {r.returncode}: {r.stderr.strip()[:200]}"
    try:
        return json.loads(r.stdout or r.stderr)
    except json.JSONDecodeError as e:
        return f"bad json: {e}"


def run_case(icarium, manifest):
    m = json.loads(manifest.read_text())
    cdir = manifest.parent
    with tempfile.TemporaryDirectory() as tmp:
        net = Path(tmp) / "net.json"
        err = elaborate(cdir / m["design"], m["top"], net)
        if err:
            return [err]
        got = check(icarium, net, cdir / m["sdc"], m["top"],
                    m.get("args", []), None)
        if isinstance(got, str):
            return [got]
    findings = [(g["rule"], src_line((it.get("dst") or {}).get("src")),
                 (it.get("dst") or {}).get("name") or "")
                for g in got.get("groups", []) for it in g.get("items", [])]
    errors = []
    unmatched = list(findings)
    for e in m["expect"]:
        hit = None
        for f in unmatched:
            if f[0] != e["rule"]:
                continue
            if "line" in e and f[1] != e["line"]:
                continue
            if "dst" in e and e["dst"] not in f[2]:
                continue
            hit = f
            break
        if hit is not None:
            unmatched.remove(hit)
        else:
            errors.append(f"missing {e}; got {[(f[0], f[1]) for f in findings]}")
    if unmatched and not m.get("allow_extra", False):
        errors.append(f"extra findings {unmatched}")
    return errors


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--icarium-bin", required=True)
    ap.add_argument("--tier", type=int, default=None)
    ap.add_argument("--case", default=None)
    args = ap.parse_args()
    manifests = sorted((ROOT / "cases").rglob("manifest.json"))
    fails = 0
    for mf in manifests:
        m = json.loads(mf.read_text())
        if args.tier is not None and m["tier"] != args.tier:
            continue
        if args.case is not None and m["id"] != args.case:
            continue
        errs = run_case(Path(args.icarium_bin), mf)
        if errs:
            fails += 1
            print(f"FAIL {m['id']}")
            for e in errs:
                print(f"    {e}")
        else:
            print(f"PASS {m['id']}")
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
