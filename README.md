# cdc-rdc-tests

A tool-neutral test suite for CDC/RDC checkers: small designs with
known-good verdicts, so any checker can measure recall and precision
against ground truth instead of against another tool's output.

Tier 1 holds 206 micro-cases covering all 36 rules, each with
firing and silence verdicts. 60 cases expect silence; 7 pass neutral
checker params (sync-depth bar); every rule fires in at least two cases.

## Tiers

- **Tier 1** — micro-seeds: one scenario per case, exact expected findings.
  Silence is a verdict too; extra findings fail.
- **Tier 2** — OpenTitan positives: real waiver-backed violations, traced
  to endpoints. Planned.
- **Tier 3** — negatives: clean production modules that must stay quiet.
  Planned.

## Sources

- `cdc*`, `rdc*` — hand-authored scenarios from rule contracts,
  one bug or one silence proof per case.
- `fx_*` — scenarios drawn from icarium's rule fixtures, oracles
  reviewed against the fixture rule sets.
- `e2e_*`, `scan_design` — drawn from icarium's e2e and suppression
  suites where the verdict is tool-agnostic.

## Oracle discipline

Each case owns a `manifest.json` with the findings its author intends.
The manifest is ground truth: the runner diffs the checker against the
manifest, never against an earlier run of the same checker. Firing
oracles locate by source line, or by destination name when the finding
names a port (ports carry no source line).

Cases whose verdict depends on tool-specific modeling — gate-structure
lint, memory opacity, reset-port policy — stay out. What this suite
asserts, any correct checker should agree with.

## Layout

- `cases/tierN/<id>/` — `design.sv`, `design.sdc`, `manifest.json`
- `docs/catalog.md` — per-rule case listing (generated, see `scripts/`)
- `docs/method.md` — how verdicts read and how to run another checker
- `docs/attributes.md` — waiver-attribute spellings and semantics
- `docs/rule-map.md` — the suite's rule numbering with contracts
- `docs/locators.md` — which endpoint each rule reports on
- `docs/sdc-subset.md` — the five SDC commands cases use
- `schema/manifest.json` — manifest schema
- `run.py` — elaborate, check, diff to oracle

## Run

```sh
python3 run.py --icarium-bin /path/to/icarium [--tier 1] [--case ID] [--ignore-notes]
```

Needs `yosys` on PATH and an icarium binary. Exit 0 when every case
matches its manifest. Cases are elaborated with Yosys 0.70;
designs use SystemVerilog-2012 plus `(* blackbox *)` stubs only,
and the runner needs Python 3 with the standard library.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). One scenario per
case; every case must pass.

## License

Apache-2.0 — see `LICENSE`.
