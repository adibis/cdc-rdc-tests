#!/usr/bin/env python3
"""Check behavioral verdicts formally with SymbiYosys.

Structural verdicts say where a checker must report; some also claim what the
hardware does, such as "two fast toggles cancel and the event is lost". Each
case in formal/cases.json carries that claim, and this script proves or
refutes it with formal/event_conservation.sv at the case's SDC clock ratio:

- loses: unconstrained events must produce a counterexample, and events
  spaced 3 destination periods apart must be conserved (so the rate is the
  only defect).
- conserves: no event is ever lost.

Every case must also hit its cover, so a vacuous run fails instead of passing.
The verdicts are tied to the manifests: a case loses events exactly when its
manifest expects CDC-013, and every case that touches CDC-013 must be listed.

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
DEPTH = 450
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
    flags = []
    if entry.get("ev_low"):
        flags.append("EV_LOW")
    if entry["output"] == "pulse":
        flags.append("PULSE")
    if spaced:
        flags.append("SPACED")
    return " ".join([f"-D {k}={v}" for k, v in d.items()] + [f"-D {f}" for f in flags])


def run(entry, task, spaced, mode):
    case_dir = os.path.join(ROOT, "cases", "tier1", entry["case"])
    hs, hd = halves(entry, os.path.join(case_dir, "design.sdc"))
    work = tempfile.mkdtemp(prefix=f"fv-{entry['case']}-{task}-")
    sby = os.path.join(work, "check.sby")
    with open(sby, "w") as f:
        f.write(f"""[options]
mode {mode}
depth {DEPTH}
multiclock on

[engines]
smtbmc yices

[script]
read -formal {defines(entry, hs, hd, spaced)} design.sv event_conservation.sv
prep -top fv_top

[files]
design.sv {os.path.join(case_dir, "design.sv")}
event_conservation.sv {HARNESS}
""")
    subprocess.run(["sby", "-f", sby], cwd=work, capture_output=True, text=True)
    status_file = os.path.join(work, "check", "status")
    status = open(status_file).read().split()[0] if os.path.exists(status_file) else "ERROR"
    shutil.rmtree(work, ignore_errors=True)
    return status


def plan(entry):
    # (task, spaced, mode, status that confirms the verdict)
    if entry["events"] == "loses":
        return [("free", False, "bmc", "FAIL"),
                ("spaced", True, "bmc", "PASS"),
                ("cover", True, "cover", "PASS")]
    if entry["events"] == "conserves":
        return [("free", False, "bmc", "PASS"),
                ("cover", False, "cover", "PASS")]
    raise SystemExit(f"{entry['case']}: unknown verdict {entry['events']}")


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

    entries = json.load(open(os.path.join(ROOT, "formal", "cases.json")))["event_conservation"]
    entries = [e for e in entries if not a.case or e["case"] == a.case]
    if not entries:
        print(f"no formal case matches {a.case}")
        return 2

    errors = consistency(entries, a.case)
    for msg in errors:
        print(f"FAIL {msg}")

    jobs = [(e, t) for e in entries for t in plan(e)]
    with concurrent.futures.ThreadPoolExecutor(a.jobs) as pool:
        results = list(pool.map(lambda j: run(j[0], j[1][0], j[1][1], j[1][2]), jobs))

    failed = len(errors)
    for (e, (task, _, _, want)), got in zip(jobs, results):
        ok = got == want
        failed += not ok
        print(f"{'PASS' if ok else 'FAIL'} {e['case']} {task}: {got}"
              + ("" if ok else f" (want {want})"))
    print(f"formal: {len(jobs) + len(errors) - failed} pass, {failed} fail")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
