# Reference tool on full EarlGrey

The founding claim — Python can't run EarlGrey scale — was an
assumption. Measured 2026-11-09 on Apple M4 Pro arm64, 25.8 GB:

- Command: `rtl-buddy-cdc 0.7.3 analyze --netlist
  t3-top_earlgrey.json --sdc top_earlgrey.sdc --format json`
  (983 MB flat netlist, same inputs as icarium's streamed run).
- Result: exit 1 (findings-bearing) after **1h32m wall**,
  single-threaded, **9.2 GB peak RSS**, 7.7 MB JSON output.
- Analysis: **0 crossings**, 22,754/22,769 flops
  unknown-domain. The 4,571 violations are domain-less noise
  (combinational-reset complaints on every flop).

Root cause, verified in the reference sources: its SDC layer
resolves `get_ports` and `get_pins` but not `get_nets`
(`sdc.py` has no `get_nets` path). This design roots its four
oscillators and all serial clocks at internal nets — standard
SDC, unavoidable here since the clocks emerge from the AST
analog block. Only the 15 `ext`-clocked flops resolve; every
other root drops silently and no clock propagates.

What this proves and what it doesn't:

- Proves: the reference processes EarlGrey scale without
  crashing or exhausting memory. Throughput is a non-issue.
- Proves: on a real top-level SDC it yields no analysis. The
  gap is modeling breadth (net roots, blackbox boundaries),
  not speed.
- Doesn't prove: anything about block scope, where port-rooted
  clocks suffice and the reference works (tier-2 parity holds
  at 17/17 pairs).

icarium on the same inputs: 65 minutes streamed, 14.8 GB peak,
1,977,807 findings, 63 unknown-domain flops, 269/444 waiver
recall with 0 missed.
