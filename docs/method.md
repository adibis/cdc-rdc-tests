# Reading verdicts

A case passes on an exact match. Each `expect` entry pairs with
one finding by rule id plus one locator. The locator is a source
`line`, or a `dst` substring for port findings. No finding may
be left over unless the manifest sets `allow_extra`. Duplicate
expects match duplicate findings one-for-one (multiset, not set).

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

Rule ids are the suite's own numbering, defined in
`docs/rule-map.md`; map them to yours before comparing. Silence
cases must stay silent under your mapping too — a category error
there is a false positive, not a naming difference. Waiver
attributes (`(* cdc_sync *)` and friends) are specified in
`docs/attributes.md`.

## Writing a runner

A runner turns one checker's output into verdicts another reader
can reproduce and challenge. Publish four things with it.

1. **Rule mapping.** For each suite rule, the checker's rule or
   rules that report it, or "unmapped". One checker rule may map
   to several suite rules if its findings carry enough detail to
   tell them apart; if they do not, map it to none of them.
2. **Supported scope.** Which suite rules, categories
   (`docs/rules.json`) and waiver attributes the checker claims to
   handle, and the checker settings used. A setting that changes a
   verdict (a depth threshold, a waiver file) is part of the scope.
3. **Command.** The exact checker version and command line, so the
   run can be repeated.
4. **Results file.** One entry per case, in the shape `run.py
   --results` writes: the case id, its state, the expected
   findings, the observed findings after mapping, and which
   expected findings were missed and which observed ones were left
   over.

Each case ends in exactly one state:

| State | Meaning | Counts as a pass |
|---|---|---|
| `pass` | Observed findings match `expect` exactly | yes |
| `fail` | A finding was missed, or an extra one was reported | no |
| `unsupported` | The case expects a rule the runner leaves unmapped, or rests on an attribute the checker does not honor | no |
| `error` | Elaboration failed, the checker crashed or timed out, or its output could not be read | no |

A score is passes out of every case in the suite, so unsupported
and error cases lower it; report the four counts beside it. A
finding from a checker rule outside the mapping is listed in the
results as unmapped, not compared: the comparison covers mapped
rules only, and the scope says which those are. Never mark a case
unsupported to hide a disagreement: a mapped rule that reports
the wrong thing is a `fail`.

## What the suite does not assert

Verdicts that depend on tool-internal modeling — gate-structure
lint, memory opacity, reset-port policy — are excluded on purpose
(see the README). What this suite asserts, any correct checker
should agree with; where reasonable checkers disagree, the case
doesn't belong here. CDC-007 is reserved (no rule claims it),
which is why no case targets it. Which endpoint each pinned line
belongs to is stated in `docs/locators.md`.
