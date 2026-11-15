# Assumptions

Every verdict in this suite holds under the assumptions below. They
are the same for every checker that runs the suite, structural or
formal: a checker is held to the same clocks, resets, startup and
traffic as every other. A case that needs anything different says so
in its manifest notes.

## Clocks

Clocks and their relations come only from `design.sdc`. Periods come
from `create_clock`. Two clocks are asynchronous only when
`set_clock_groups -asynchronous` says so; any other pair is related,
as SDC defines it. No verdict relies on a checker guessing a
relation. See [sdc-subset.md](sdc-subset.md).

## Reset

A reset is what the RTL makes it: async when it is in the
sensitivity list, sync otherwise, with the polarity as written.
Reset ports are typed by `set_input_delay` like any other input.
The formal harnesses hold every reset asserted through warm-up and
never assert it again.

So reset assertion during operation is out of scope. The RDC cases
are about reset structure and release. None claims anything about
what a receiver captures when a reset asserts under it.

## Startup

A flop with no reset starts unknown. No case gives a register an
initial value, and no verdict depends on one. The formal harnesses
start from arbitrary state, run a warm-up long enough to flush every
synchronizer, and ignore any value that still depends on unreset
state: the first gray change after warm-up, and events before the
settle phase ends.

## Traffic

Inputs are unconstrained unless a verdict states a rate or a
protocol. Structurally, any input may change on any edge of the
clock it is typed to. Each formal harness states its traffic once,
and every case it checks gets that same traffic:

| Harness | Clocks after warm-up | Traffic | Depth |
|---|---|---|---|
| `event_conservation.sv` | SDC ratio, free phase | events unconstrained ("loses" must fail) or spaced 3 destination periods apart (must pass); with a ready output only accepted events count | 450 |
| `gray_sequence.sv` | tied, or free for a handshake | no data inputs: the source counts on its own | 160 |
| `clock_switch.sv` | free, every phase at least 3 steps | the select is rewritten only after the previous switch has landed; the negative control fails under the same assumption | 200 |

## Bounds

The formal checks are bounded: no counterexample within the depth
above, in formal steps, plus a cover that must be reached so a vacuous
run cannot pass. They are not unbounded proofs. A bug verdict rests on
a counterexample, which is a concrete trace and holds outright; a
quiet verdict holds only to the depth, under the assumptions on this
page.

## Out of scope

- **MTBF.** The resolution-time rules (CDC-014, CDC-016) are about
  shape, and CDC-018 is a latency policy. How much margin a design
  needs depends on the flop library, clock rates and data rates,
  which no case carries.
- **Reset assertion.** See [Reset](#reset).
- **Timing.** A verdict says nothing about setup, hold or skew
  margins.
