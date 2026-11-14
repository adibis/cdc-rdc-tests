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
python3 scripts/compile-check.py --tool verilator
python3 scripts/compile-check.py --tool yosys
python3 run.py --icarium-bin <path-to-icarium>
python3 run.py --icarium-bin <path-to-icarium> --ignore-notes
```

Every case must compile, synthesize and pass in both modes, and
every rule must still fire in at least two cases. CI also runs
Xezim, slang and the yosys-slang front end.

## Certifying your contribution

Contributions must be certified as open source under the
[Developer Certificate of Origin](https://developercertificate.org/)
(DCO). On your first contribution, add your name to
[CONTRIBUTORS](CONTRIBUTORS) in the same pull request; that
certifies this and all your future contributions. Your name
must match the author name on your commits; CI checks it.

Designs must be your own or openly licensed. Never contribute
proprietary RTL, even reduced.

Contributions are licensed under the Apache License 2.0
([LICENSE](LICENSE)). There is no separate contributor
agreement.

## AI policy

AI tools may help you write a contribution; they may not
submit one. A human is in the loop on every issue, pull
request and commit, and is responsible for reviewing, testing
and understanding what they submit. By signing CONTRIBUTORS
you certify that generated content is effectively your own
work. Disclose significant AI assistance in the pull request.
A generated verdict needs the same justification from the rule
contract as a hand-written one.

## Code of conduct

The suite follows the
[Contributor Covenant 2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).
Report conduct concerns privately to the maintainer (adibis on
GitHub).
