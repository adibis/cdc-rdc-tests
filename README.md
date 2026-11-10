# icarium_benchmark

An independent CDC/RDC benchmark corpus: small designs with known-good
verdicts, so any checker can measure recall and precision against ground
truth instead of against another tool's output.

Tier 1 holds 208 micro-cases covering all 36 icarium rules, each with
firing and silence verdicts. 61 cases expect silence; 7 pass extra
checker args (sync-depth bar); every rule fires in at least two cases.

## Tiers

- **Tier 1** — micro-seeds: one scenario per case, exact expected findings.
  Silence is a verdict too; extra findings fail.
- **Tier 2** — OpenTitan positives: real waiver-backed violations, traced
  to endpoints. Planned.
- **Tier 3** — negatives: clean production modules that must stay quiet.
  Planned.

## Sources

- `cdc*`, `rdc*` — hand-authored scenarios from rule contracts and unit
  test conversions, one bug or one silence proof per case.
- `fx_*` — migrated from icarium's rule fixtures, oracles reviewed
  against the fixture rule sets.
- `e2e_*`, `scan_design` — migrated from icarium's e2e and suppression
  suites where the verdict is tool-agnostic.

## Oracle discipline

Each case owns a `manifest.json` with the findings its author intends.
Expectations are calibrated once against reality at seed creation, then
frozen; the runner diffs the checker against the manifest, never against
a previous run of the same checker. Firing oracles locate by source line,
or by destination name when the finding names a port (ports carry no
source line).

Cases whose verdict depends on tool-specific modeling — gate-structure
lint, memory opacity, reset-port policy — stay in icarium's own suite and
are not migrated here. What this corpus asserts, any correct checker
should agree with.

## Layout

- `cases/tierN/<id>/` — `design.sv`, `design.sdc`, `manifest.json`
- `schema/manifest.json` — manifest schema
- `run.py` — elaborate, check, diff to oracle

## Run

```sh
python3 run.py --icarium-bin /path/to/icarium [--tier 1] [--case ID]
```

Needs `yosys` on PATH and an icarium binary. Exit 0 when every case
matches its manifest.
