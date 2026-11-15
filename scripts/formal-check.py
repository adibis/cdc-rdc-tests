#!/usr/bin/env python3
"""Check behavioral verdicts formally with SymbiYosys.

Structural verdicts say where a checker must report; some also claim what the
hardware does, such as "two fast toggles cancel and the event is lost". Each
case in formal/cases.json carries that claim, and this script checks it by
bounded model checking. A counterexample refutes a claim; a pass means none
exists within the harness depth (DEPTH, GRAY_DEPTH, SWITCH_DEPTH formal
steps), not that none exists at all.

event_conservation (formal/event_conservation.sv, at the case's SDC ratio):

- loses: unconstrained events must produce a counterexample, and events
  spaced 3 destination periods apart must be conserved (so the rate is the
  only defect).
- conserves: no accepted event is lost within the depth.

The verdicts are tied to the manifests: a case loses events exactly when its
manifest expects CDC-013, and every case that touches CDC-013 must be listed.

gray_sequence (formal/gray_sequence.sv): every case named for gray coding or
carrying a cdc_gray mark must be listed, and its crossing value must step
through reflected gray order within the depth. A mark is a promise; this
checks it is kept.

clock_switch (formal/clock_switch.sv): clean = no runt pulse on the muxed
clock through any select change within the depth, under the harness's
traffic assumption;
runt = a counterexample even under it. A case is runt exactly when its
manifest expects CDC-010.

Every case must also hit its cover, so a vacuous run fails instead of passing.

Usage: formal-check.py [--case ID] [--jobs N]
Needs sby, yosys and yices on PATH (all in OSS CAD Suite).
"""

import argparse
import concurrent.futures
import glob
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HARNESS = os.path.join(ROOT, "formal", "event_conservation.sv")
GRAY_HARNESS = os.path.join(ROOT, "formal", "gray_sequence.sv")
DEPTH = 450
GRAY_DEPTH = 160
SWITCH_HARNESS = os.path.join(ROOT, "formal", "clock_switch.sv")
SWITCH_DEPTH = 200
RULE = "CDC-013"  # the structural rule whose claim event conservation checks


def periods(sdc_path):
    out = {}
    for line in open(sdc_path):
        m = re.match(r"\s*create_clock\b.*-period\s+([\d.]+).*get_ports\s+\{?(\w+)", line)
        if m:
            out[m.group(2)] = float(m.group(1))
    return out


def halves(entry, sdc):
    p = periods(sdc)
    src, dst = p[entry["src"]], p[entry["dst"]]
    base = min(src, dst)
    hs, hd = src / base, dst / base
    if hs != int(hs) or hd != int(hd):
        raise SystemExit(f"{entry['case']}: clock ratio {src}:{dst} is not an integer ratio")
    return int(hs), int(hd)


def defines(entry, hs, hd, spaced):
    m = json.load(open(os.path.join(ROOT, "cases", "tier1", entry["case"], "manifest.json")))
    d = {"DUT": m["top"], "SRC_HALF": hs, "DST_HALF": hd,
         "P_SRC": entry["src"], "P_DST": entry["dst"], "P_EV": entry["ev"], "P_OUT": entry["out"]}
    if "rst" in entry:
        d["P_RST"] = entry["rst"]
    if "ready" in entry:
        d["P_RDY"] = entry["ready"]
    flags = []
    if entry.get("ev_low"):
        flags.append("EV_LOW")
    if entry["output"] == "pulse":
        flags.append("PULSE")
    if spaced:
        flags.append("SPACED")
    return " ".join([f"-D {k}={v}" for k, v in d.items()] + [f"-D {f}" for f in flags])


def gray_defines(entry):
    m = json.load(open(os.path.join(ROOT, "cases", "tier1", entry["case"], "manifest.json")))
    d = {"DUT": m["top"], "W": entry["width"], "P_SRC": entry["src"], "P_DST": entry["dst"],
         "P_RST": entry["rst"], "P_OUT": entry["out"]}
    if "in" in entry:
        d["P_IN"] = entry["in"]
    flags = ["FREE"] if entry["clocks"] == "free" else []
    return " ".join([f"-D {k}={v}" for k, v in d.items()] + [f"-D {f}" for f in flags])


def run(kind, entry, task, spaced, mode):
    case_dir = os.path.join(ROOT, "cases", "tier1", entry["case"])
    if kind == "gray_sequence":
        harness, depth, defs = GRAY_HARNESS, GRAY_DEPTH, gray_defines(entry)
    elif kind == "clock_switch":
        top = json.load(open(os.path.join(case_dir, "manifest.json")))["top"]
        harness, depth, defs = SWITCH_HARNESS, SWITCH_DEPTH, f"-D DUT={top}"
    else:
        hs, hd = halves(entry, os.path.join(case_dir, "design.sdc"))
        harness, depth, defs = HARNESS, DEPTH, defines(entry, hs, hd, spaced)
    work = tempfile.mkdtemp(prefix=f"fv-{entry['case']}-{task}-")
    sby = os.path.join(work, "check.sby")
    with open(sby, "w") as f:
        f.write(f"""[options]
mode {mode}
depth {depth}
multiclock on

[engines]
smtbmc yices

[script]
read -formal {defs} design.sv harness.sv
prep -top fv_top

[files]
design.sv {os.path.join(case_dir, "design.sv")}
harness.sv {harness}
""")
    subprocess.run(["sby", "-f", sby], cwd=work, capture_output=True, text=True)
    status_file = os.path.join(work, "check", "status")
    status = open(status_file).read().split()[0] if os.path.exists(status_file) else "ERROR"
    shutil.rmtree(work, ignore_errors=True)
    return status


def plan(kind, entry):
    # (task, spaced, mode, status that confirms the verdict)
    if kind == "gray_sequence":
        want = {"gray": "PASS", "not_gray": "FAIL"}[entry["sequence"]]
        return [("sequence", False, "bmc", want), ("cover", False, "cover", "PASS")]
    if kind == "clock_switch":
        want = {"clean": "PASS", "runt": "FAIL"}[entry["switch"]]
        return [("switch", False, "bmc", want), ("cover", False, "cover", "PASS")]
    if entry["events"] == "loses":
        return [("free", False, "bmc", "FAIL"),
                ("spaced", True, "bmc", "PASS"),
                ("cover", True, "cover", "PASS")]
    if entry["events"] == "conserves":
        return [("free", False, "bmc", "PASS"),
                ("cover", False, "cover", "PASS")]
    raise SystemExit(f"{entry['case']}: unknown verdict {entry['events']}")


def gray_consistency(entries, only):
    """Every case that rests on gray coding must have a gray verdict."""
    errors = []
    listed = {e["case"] for e in entries}
    for path in sorted(glob.glob(os.path.join(ROOT, "cases", "*", "*", "manifest.json"))):
        m = json.load(open(path))
        if only and m["id"] != only:
            continue
        design = open(os.path.join(os.path.dirname(path), m["design"])).read()
        if ("gray" in m["id"] or "cdc_gray" in design) and m["id"] not in listed:
            errors.append(f"{m['id']}: rests on gray coding but has no gray_sequence verdict in formal/cases.json")
    return errors


def switch_consistency(entries):
    """A clock-switch case is runt exactly when its manifest expects CDC-010."""
    errors = []
    for e in entries:
        m = json.load(open(os.path.join(ROOT, "cases", "tier1", e["case"], "manifest.json")))
        fires = any(x["rule"] == "CDC-010" for x in m["expect"])
        if fires != (e["switch"] == "runt"):
            errors.append(f"{e['case']}: formal verdict '{e['switch']}' but the manifest "
                          f"{'expects' if fires else 'does not expect'} CDC-010")
    return errors


def consistency(entries, only):
    """Formal verdicts must agree with the manifests, and cover every case."""
    errors = []
    listed = {e["case"] for e in entries}
    for path in sorted(glob.glob(os.path.join(ROOT, "cases", "*", "*", "manifest.json"))):
        m = json.load(open(path))
        if only and m["id"] != only:
            continue
        fires = any(x["rule"] == RULE for x in m["expect"])
        touches = fires or RULE.lower().replace("-", "") in m["id"]
        if touches and m["id"] not in listed:
            errors.append(f"{m['id']}: touches {RULE} but has no formal verdict in formal/cases.json")
    for e in entries:
        m = json.load(open(os.path.join(ROOT, "cases", "tier1", e["case"], "manifest.json")))
        fires = any(x["rule"] == RULE for x in m["expect"])
        if fires != (e["events"] == "loses"):
            errors.append(f"{e['case']}: formal verdict '{e['events']}' but the manifest "
                          f"{'expects' if fires else 'does not expect'} {RULE}")
    return errors


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--case", help="check one case id")
    ap.add_argument("--jobs", type=int, default=os.cpu_count() or 2)
    a = ap.parse_args()

    spec = json.load(open(os.path.join(ROOT, "formal", "cases.json")))
    kinds = {k: [e for e in spec[k] if not a.case or e["case"] == a.case]
             for k in ("event_conservation", "gray_sequence", "clock_switch")}
    if not any(kinds.values()) and not a.case:
        print("formal/cases.json lists no cases")
        return 2

    errors = consistency(kinds["event_conservation"], a.case)
    errors += gray_consistency(kinds["gray_sequence"], a.case)
    errors += switch_consistency(kinds["clock_switch"])
    for msg in errors:
        print(f"FAIL {msg}")

    jobs = [(k, e, t) for k, es in kinds.items() for e in es for t in plan(k, e)]
    with concurrent.futures.ThreadPoolExecutor(a.jobs) as pool:
        results = list(pool.map(lambda j: run(j[0], j[1], j[2][0], j[2][1], j[2][2]), jobs))

    failed = len(errors)
    for (_, e, (task, _, _, want)), got in zip(jobs, results):
        ok = got == want
        failed += not ok
        print(f"{'PASS' if ok else 'FAIL'} {e['case']} {task}: {got}"
              + ("" if ok else f" (want {want})"))
    print(f"formal: {len(jobs) + len(errors) - failed} pass, {failed} fail")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
