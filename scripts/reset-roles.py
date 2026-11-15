#!/usr/bin/env python3
"""Check that a dual-use reset case keeps both uses after synthesis.

A case that expects RDC-011 claims one reset net is both an async reset and
a sync reset. A use that synthesis can remove is no claim at all: a sync
branch under the async branch's own condition is dead, and an output nobody
observes is swept. This script runs Yosys `synth` on every such case and
requires one net (through inverters and buffers) to reach an async reset pin
on one flop and the sync reset or D cone of a different flop.

Usage: reset-roles.py [--case ID] [--bin YOSYS]
"""

import argparse
import glob
import json
import os
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RULE = "RDC-011"


def synth(yosys, case_dir, top, out):
    script = (f'read_verilog -sv "{os.path.join(case_dir, "design.sv")}"; '
              f"hierarchy -check -top {top}; synth -flatten -top {top}; "
              f'write_json "{out}"')
    r = subprocess.run([yosys, "-q", "-p", script], capture_output=True, text=True)
    return r.returncode == 0, r.stderr.strip()


def roles(netlist, top):
    mod = netlist["modules"][top]
    cells = mod["cells"].values()
    driver = {}
    for c in cells:
        for p, bits in c["connections"].items():
            if c["port_directions"].get(p) == "output":
                for b in bits:
                    driver[b] = c

    def root(b):
        # Inverters and buffers keep the net's identity.
        while b in driver and driver[b]["type"] in ("$_NOT_", "$_BUF_"):
            b = driver[b]["connections"]["A"][0]
        return b

    def is_flop(c):
        t = c["type"]
        return t.startswith(("$_DFF_", "$_SDFF_", "$_DFFE_", "$_SDFFE_", "$_SDFFCE_", "$_DFFSR"))

    def d_cone(bit):
        seen, todo = set(), [bit]
        while todo:
            b = todo.pop()
            if b in seen or not isinstance(b, int):
                continue
            seen.add(b)
            c = driver.get(b)
            if c is None or is_flop(c):
                continue
            for p, bits in c["connections"].items():
                if c["port_directions"].get(p) == "input":
                    todo.extend(bits)
        return {root(b) for b in seen if isinstance(b, int)}

    async_of, sync_of = {}, {}
    for i, c in enumerate(cells):
        if not is_flop(c):
            continue
        t, conn = c["type"], c["connections"]
        a, s = set(), set()
        # $_DFF_[NP][NP][01]_ carries an async R; $_DFFSR* async S and R.
        if (t.startswith("$_DFF_") and len(t) == 10) or t.startswith("$_DFFSR"):
            for p in ("R", "S"):
                if p in conn:
                    a.add(root(conn[p][0]))
        if t.startswith(("$_SDFF", "$_SDFFE", "$_SDFFCE")) and "R" in conn:
            s.add(root(conn["R"][0]))
        s |= d_cone(conn["D"][0])
        async_of[i], sync_of[i] = a, s
    for i, a in async_of.items():
        for j, s in sync_of.items():
            if i != j and (a & s) - async_of[j]:
                return True
    return False


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--case")
    ap.add_argument("--bin", default="yosys")
    a = ap.parse_args()
    passed = failed = 0
    for path in sorted(glob.glob(os.path.join(ROOT, "cases", "*", "*", "manifest.json"))):
        m = json.load(open(path))
        if a.case and m["id"] != a.case:
            continue
        if not any(x["rule"] == RULE for x in m["expect"]):
            continue
        with tempfile.TemporaryDirectory() as tmp:
            out = os.path.join(tmp, "net.json")
            ok, err = synth(a.bin, os.path.dirname(path), m["top"], out)
            if not ok:
                print(f"FAIL {m['id']}: synthesis failed: {err.splitlines()[-1:] or ''}")
                failed += 1
                continue
            if roles(json.load(open(out)), m["top"]):
                print(f"PASS {m['id']}")
                passed += 1
            else:
                print(f"FAIL {m['id']}: after synthesis no reset net is both an async reset "
                      "and a sync reset on different flops")
                failed += 1
    print(f"reset roles: {passed} pass, {failed} fail")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
