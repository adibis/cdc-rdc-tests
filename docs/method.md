# Reading verdicts

A case passes when the checker's findings match the manifest exactly:
every `expect` entry matches one finding by rule id plus one locator
(a source `line`, or a destination-name substring `dst` for port
findings, which carry no source line), and no finding is left over
unless the manifest sets `allow_extra`. Duplicate expects match
duplicate findings one-for-one (multiset, not set).

## What the oracles assert

- **Firing cases** plant one bug shape the rule must catch: an
  unsynchronized crossing, a foreign reset release, an async mux
  select. The line points at the construct, not the symptom. Each
  expect carries the finding's `severity` (`error`, `warning`, or
  `note`, taken from the rule contract).
- **Silence cases** plant the approved pattern — two-flop synchronizer,
  same-domain capture, generated-clock sync — and require zero
  findings. They guard precision: a checker that fires everywhere
  fails the suite.
- **`params`** holds neutral checker parameters the scenario needs
  (today only `sync_depth`, default 2, consumed by CDC-002 and
  CDC-022). The design and the intent stay portable; the runner
  translates params to flags.
- **`--ignore-notes`** drops note-severity expects and findings on
  both sides, for violation-oriented checkers that keep no
  informational records. Strict mode (default) pins everything.

## Running another checker

`run.py` drives icarium, but the case contract is tool-agnostic:

1. Elaborate `design.sv` with stock Yosys: `read_verilog -sv`,
   `hierarchy -check -top <top>`, `proc`, `flatten`. Four cases use
   `(* blackbox *)` macro models (CDC-022 XPM-style, CDC-025 macro);
   a checker that flattens everything must treat black-box cells as
   opaque endpoints instead.
2. Apply `design.sdc`. The subset is small and standard:
   `create_clock` (port roots), `create_generated_clock`
   (`-divide_by`, net targets), `set_clock_groups -asynchronous`,
   `set_input_delay -clock`, `set_output_delay -clock` (one
   boundary case). No Tcl substitution, no wildcards.
3. Compare your findings to `expect` by (rule, line-or-dst).

Rule ids are the corpus's own numbering, defined in
`docs/rule-map.md`; map them to yours before comparing. Silence
cases must stay silent under your mapping too — a category error
there is a false positive, not a naming difference. Waiver
attributes (`(* cdc_sync *)` and friends) are specified in
`docs/attributes.md`.

## What the corpus does not assert

Verdicts that depend on tool-internal modeling — gate-structure
lint, memory opacity, reset-port policy — are excluded on purpose
(see the README). What this corpus asserts, any correct checker
should agree with; where reasonable checkers disagree, the case
doesn't belong here. CDC-007 is reserved (no rule claims it),
which is why no case targets it. Which endpoint each pinned line
belongs to is stated in `docs/locators.md`.
