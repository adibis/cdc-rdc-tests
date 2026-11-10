# Reading verdicts

A case passes when the checker's findings match the manifest exactly:
every `expect` entry matches one finding, and no finding is left over
(unless the manifest sets `allow_extra`). Matching keys on rule id plus
one locator: a source `line` for cell findings, a destination-name
substring `dst` for port findings (ports carry no source line).

## What the oracles assert

- **Firing cases** plant one bug shape the rule must catch: an
  unsynchronized crossing, a foreign reset release, an async mux
  select. The line points at the construct, not the symptom.
- **Silence cases** plant the approved pattern — two-flop synchronizer,
  same-domain capture, generated-clock sync — and require zero
  findings. They guard precision: a checker that fires everywhere
  fails the suite.
- **`args`** holds checker flags the scenario needs (today only
  `--sync-depth` for depth-bar rules). The design and the intent stay
  portable; flags are invocation detail.

## Running another checker

`run.py` drives icarium, but the case contract is tool-agnostic:

1. Elaborate `design.sv` with stock Yosys: `read_verilog -sv`,
   `hierarchy -check -top <top>`, `proc`, `flatten`.
2. Apply `design.sdc` (plus `args` equivalents if your tool has them).
3. Compare your findings to `expect` by (rule, line-or-dst).

Rule ids follow the Accellera CDC/RDC 1.0 numbering icarium
implements; map them to your own ids before comparing. Silence cases
must stay silent under your mapping too — a category error there is a
false positive, not a naming difference.

## What the corpus does not assert

Verdicts that depend on tool-internal modeling — gate-structure lint,
memory opacity, reset-port policy — are excluded on purpose (see the
README). What this corpus asserts, any correct checker should agree
with; where reasonable checkers disagree, the case doesn't belong here.
