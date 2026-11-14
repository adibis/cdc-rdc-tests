# Contributing to icarium_benchmark

New cases welcome. One scenario per case: one bug or one
silence proof, with exact expected findings. Silence is a
verdict too — extra findings fail the case.

## Before every commit

```sh
python3 run.py --icarium-bin <path-to-icarium>
```

The full corpus must pass, and every rule must still fire
in at least two cases.

## License

Contributions are accepted under the Apache-2.0 license
(`LICENSE`); no separate contributor agreement needed.
