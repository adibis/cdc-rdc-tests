# Contributing to cdc-rdc-tests

New cases welcome. One scenario per case: one bug shape, or one
silence proof, with exact expected findings. A case that needs
two paragraphs to explain its verdict is two cases. Silence is a
verdict too: extra findings fail the case.

## Anatomy

```
cases/tier1/<id>/
  design.sv      # the scenario, SystemVerilog-2012
  design.sdc     # clocks, async groups, port typing
  manifest.json  # id, top, sdc, expect, notes
```

Name the id after its target: `cdc<NN>_<shape>` or
`rdc<NN>_<shape>`. Keep the design minimal, the smallest RTL
that still shows the shape, and comment the intent at the top.

The manifest pins the verdict:

```json
{
  "id": "cdc001_async_data",
  "tier": 1,
  "design": "design.sv",
  "top": "cdc001_async_data",
  "sdc": "design.sdc",
  "expect": [
    {"rule": "CDC-001", "line": 11, "severity": "error"}
  ],
  "notes": "Unsynchronized flop-to-flop crossing across async groups. The capture flop must report."
}
```

Locate by source `line`, or by `dst` substring when the finding
names a port. Set `allow_extra` only when the verdict truly
varies by checker; set `params` only when the scenario needs a
non-default checker knob. Notes describe the design, not the
tool that ran it.

## Writing the oracle

Write the oracle from the rule contract (`docs/rule-map.md`),
then run the case and read any mismatch as a question: either
the design shows more than you intended, or the checker sees
less than it should. Shrink the design before widening the
oracle. An empty `expect` must mean the approved pattern, not
an accidentally quiet design.

## Before every commit

```sh
python3 scripts/gen-catalog.py
python3 run.py --icarium-bin <path-to-icarium>
python3 run.py --icarium-bin <path-to-icarium> --ignore-notes
```

Every case must pass in both modes, and every rule must still
fire in at least two cases.

## License

Contributions are accepted under the Apache-2.0 license
(`LICENSE`); no separate contributor agreement needed.
