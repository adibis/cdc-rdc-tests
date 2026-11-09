# icarium_benchmark

An independent CDC/RDC benchmark corpus: small designs with known-good
verdicts, so any checker can measure recall and precision against ground
truth instead of against another tool's output.

## Tiers

- **Tier 1** — micro-seeds: one crossing per case, exact expected findings.
  Silence is a verdict too; extra findings fail.
- **Tier 2** — OpenTitan positives: real waiver-backed violations, traced
  to endpoints. Planned.
- **Tier 3** — negatives: clean production modules that must stay quiet.
  Planned.

## Oracle discipline

Each case owns a `manifest.json` with the findings its author intends.
Expectations are calibrated once against reality at seed creation, then
frozen; the runner diffs the checker against the manifest, never against
a previous run of the same checker.

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
