# Notes for AI agents

Read [CONTRIBUTING.md](CONTRIBUTING.md) first; its rules apply to you, including
the AI policy.

- A human reviews and submits everything. Draft issues and pull requests for
  your user to post; never open them yourself.
- Never edit `CONTRIBUTORS`. Only a human can certify a contribution.
- A manifest is ground truth written from the rule contract. Never change one
  to match what a checker reported; a mismatch is a question about the design
  or the checker, answered before any edit.
- Keep every case compiling and synthesizing: `python3 scripts/compile-check.py`
  with `--tool verilator` and `--tool yosys`.
- `docs/catalog.md` and the case counts in `README.md` and `docs/attributes.md`
  are generated; re-run `python3 scripts/gen-catalog.py`. CI runs it with
  `--check`. A README results row must be scored out of the current case count.
- A CDC-013 case, and any case that rests on gray coding, needs a formal
  verdict in `formal/cases.json` that `scripts/formal-check.py` confirms. Never weaken the harness or drop a cover
  to make a check pass.
