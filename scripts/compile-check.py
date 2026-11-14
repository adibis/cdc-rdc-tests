#!/usr/bin/env python3
"""Compile every case with a SystemVerilog tool that has no CDC/RDC checks.

A case's only defect must be its CDC/RDC shape. If a simulator rejects the
design, the case tests a parser, not a checker. Lint warnings are allowed:
many cases are deliberately bad hardware.

Usage: compile-check.py --tool verilator|xezim [--bin PATH] [--case ID]
"""

import argparse
import glob
import json
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Each tool's parse + elaborate mode, warnings non-fatal.
TOOLS = {
    "verilator": lambda b, top, src: [b, "--lint-only", "-Wno-fatal", "--top-module", top, src],
    "xezim": lambda b, top, src: [b, "--compile", "-s", top, src],
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tool", required=True, choices=sorted(TOOLS))
    ap.add_argument("--bin", help="tool binary (default: --tool on PATH)")
    ap.add_argument("--case", help="check one case id")
    a = ap.parse_args()

    checked = failed = 0
    manifests = sorted(glob.glob(os.path.join(ROOT, "cases", "*", "*", "manifest.json")))
    for path in manifests:
        m = json.load(open(path))
        if a.case and m["id"] != a.case:
            continue
        checked += 1
        cmd = TOOLS[a.tool](a.bin or a.tool, m["top"], m["design"])
        r = subprocess.run(cmd, cwd=os.path.dirname(path), capture_output=True, text=True)
        if r.returncode != 0:
            failed += 1
            print(f"FAIL {m['id']}")
            for line in (r.stdout + r.stderr).strip().splitlines()[:6]:
                print(f"  {line}")
    print(f"{a.tool}: {checked - failed} compile, {failed} fail")
    if checked == 0:
        print(f"no case matches {a.case}")
        return 2
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
