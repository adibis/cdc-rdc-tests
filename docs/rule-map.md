# Rule map

The suite's own CDC/RDC numbering with contracts. Foreign
checkers map these ids to their own before comparing verdicts.

## CDC-001 (error) — Unsynchronized control crossing

The destination flop has no follow-on synchronizer in its own
clock: a single-bit signal lands and is used directly, with no
second stage to filter metastability. Add a two-flop (2FF)
chain, or assert
(* cdc_sync *) on a vetted synchronizer, (* cdc_static *) on a
source held constant, (* cdc_handshake *) on a capture register.
Typed input ports fire as sources, and crossings leaving through
an output port fire on the boundary; untyped inputs defer to
CDC-011, which owns the missing-typing verdict.

## CDC-002 (warning) — Insufficient synchronizer depth

A synchronizer chain exists but is shorter than the site minimum
(--sync-depth, default 2): raise the depth or lower the bar.
Silent at the default unless a project explicitly requires more.
Each added stage buys a cycle of settling time; the minimum
is the project's failure-rate margin.

## CDC-003 (error) — Combinational logic on the way to a synchronizer

Source-domain signals combine through a gate before the
synchronizer: the gate can glitch across source cycles and a
2FF cannot filter the transient. Synchronize each source bit
first, then combine in the destination domain.

## CDC-004 (error) — Multi-bit bus crossing without gating or gray-coding

A multi-bit path crosses domains with no coherence mechanism:
lanes settle on different cycles, so the destination can sample
a value never sent. Gate the bus behind a synchronized enable,
gray-code it (one lane moves per transfer) into a multi-bit
chain, or assert the promise.

## CDC-005 (warning) — Reconvergent synchronizers

One source flop fans out to independent synchronizer chains
whose outputs recombine downstream: each chain resolves
metastability on its own cycle, so the recombination can see
a value pair never true at the source. Synchronize once and
fan out after, or prove the skew harmless.

## CDC-006 (error) — Glitchy combinational source on a control crossing

A synchronizer first stage traces back through logic alone to
top-level ports, with no registering flop: the chain can sample
a transient no stable input ever held. Register the source in
its own domain before synchronizing it.

## CDC-008 (error) — Clock signal used as data

A bit that drives a flop clock (or an SDC clock port) also feeds
a non-clock input: clocks ride low-skew networks and sampling
them as data breaks STA. Clock-distribution cells, clock pins,
and off-chip forwarding are exempt; the rest is a wiring bug.

## CDC-009 (warning) — Pulse-width risk on fast-to-slow data crossings

A single-bit flop crossing runs fast to slow (source period
times 1.5 below the destination period) and the source flop
is an edge detector: a 1-cycle pulse may slip between slow
edges. Stretch the pulse, toggle it, or handshake it.

## CDC-010 (error) — Glitch on the clock network from a wrong-domain control signal

A clock mux select or gate enable is driven from a domain
async to every clock the cell gates: the transition chops the
output clock into runt pulses no sink synchronizer can heal.
Synchronize the control into one of the gated-clock domains.

## CDC-011 (warning) — Unconstrained primary input captured by clocked logic

A top input with no set_input_delay clock typing reaches a
flop D or SRST pin: one domain is a methodology warning, two
or more an error no typing can silence. Type the port, then
synchronize the foreign side when the domains disagree.

## CDC-012 (warning) — Gated bus crossing without synced-back handshake

A gated multi-bit crossing has no handshake holding the
payload: the destination latches cycles after the request,
by which time the source may have moved on. Hold the source
payload until a synced-back ack confirms the sample.

## CDC-013 (warning) — Toggle-synchronizer event loss on fast-to-slow crossing

A toggling source runs fast to slow past the period ratio:
two toggles between destination samples cancel to zero edges
and both events are silently lost. A handshake or
backpressure closes it. An XOR tail does not: it turns each
toggle into a pulse, but cancelled toggles never reach it. The
bar is a 1.5x period ratio: the rule fires when the source
period times 1.5 still sits below the destination period.
Both periods must come from declared clocks. An undeclared
frequency cannot ground a fast-to-slow claim.

## CDC-014 (error) — Combinational logic between synchronizer stages

A gate sits between two stages of a synchronizer: the second
stage may sample the first while still metastable, destroying
the resolution time the chain was meant to provide. Move the
gate past the chain's final stage.

## CDC-015 (error) — Synchronizer chain released by a foreign-domain reset

A synchronizer chain takes its async reset from another clock
domain: every foreign deassertion races the chain clock, so the
resolving flops never reach steady state. Reset the chain from
its own domain, or synchronize the reset into it. Fires beside
RDC-001 on the shared shape by design: this rule frames the
chain's release, RDC-001 the consumer's, each a different fix.

## CDC-016 (error) — Opposite-edge stages in a synchronizer chain

Adjacent chain stages sample on opposite edges of one clock,
halving the resolution time a same-edge chain would provide.
The RTL reads as a symmetric 2FF, but MTBF roughly halves.
Sample every stage on the same edge.

## CDC-017 (error) — Transparent latch in a CDC path

A latch sits between a source flop and a destination flop in
different clocks: while the enable holds, the foreign signal
flows transparently to the destination with no resolution
time. Replace the latch with a 2FF chain on the dst clock.

## CDC-018 (warning) — Cascaded synchronizer chain past the depth threshold

A destination chain runs deeper than the threshold (default
4): two stacked 2FF syncs, or a refactor leftover. Extra
stages add latency without improving resolution. Trim to 2,
raise the threshold, or vouch the head.

## CDC-019 (warning) — Independently-synced one-hot decode across CDC

One comb decoder fans to two or more 1-bit source flops that
cross to the same domain: lanes change together upstream but
resolve apart, so the destination can sample combinations the
encoder never emits. Gray-code the source or handshake it.

## CDC-020 (warning) — Sliced-bus reconvergence across CDC

A multi-bit source register fans lane by lane to two or more
destinations in one domain: each lane resolves apart, so the
destination can sample mixes the source never emits. Gray-code
the source, handshake it, or sync the bus whole.

## CDC-021 (error) — Flop clock driven by an undeclared port

A top-level input port drives flop clocks with no create_clock
behind it. Undeclared clocks appear in no async group, so every
other check touching the domain silently skips. Declare it.

## CDC-022 (warning) — Synchronizer primitive shallower than required depth

A CDC macro carries its stage count as a parameter, not a flop
chain, so CDC-002 cannot see it. Under a project minimum the
instance reads short. Raise the parameter or lower the bar.
A macro is a blackbox instantiation recognized by its type
name (XPM primitives and site-registered types); its depth
comes from the vendor depth parameter (DEST_SYNC_FF and
kin). XPM absences read the documented default of 4 — a
default the vendor guarantees, not one the checker invents —
while a site-registered macro without its parameter stays
silent. The bar is the same `sync_depth` minimum CDC-002
uses, so one number governs both.

## CDC-023 (warning) — Clock net driven by a combine of declared clocks

A gate mixes two or more declared clocks onto one net: the net
glitches, runs at no declared frequency, and leaves its flops
domainless. Gate one clock, or mux instead of mixing.

## CDC-024 (warning) — Single source fanning to multiple synchronizers

One source bit reaches two or more synchronizer chains: each
chain resolves metastability on its own edge, so the set only
holds when the destinations never recombine what they latched
apart. CDC-005 proves the recombination; this rule flags the
fanout itself for the independence judgement.

## CDC-025 (warning) — Unresolved clock association

A crossing endpoint has no clock association: undriven flop
clock, macro or memory output, unhandled primitive, or an
untyped input the other port rules do not own. One finding
per endpoint names the reason and the fanout; per-pair sync
verdicts on unclocked endpoints would be noise. Type the
source, model the macro, or waive after review.

## CDC-026 (note) — Multiclock crossing leg-pair report

A crossing whose source or receiver runs on a muxed clock:
each side may arrive on several legs, and one leg pair can be
safe while another is not. One finding per endpoint lists the
clock sets, the mux selections behind them, every leg pair with
its relationship, and the destination chain depth. Multiple
clocks alone prove nothing; review the pairs, then waive or fix.

## RDC-001 (error) — Async reset released from a foreign clock domain

A flop's async reset fans in from a register in another clock
domain: every foreign deassertion races the local clock, so
the flop never reaches a clean out-of-reset state. Reset it
from its own domain's tree, or synchronize the reset across.

## RDC-002 (error) — Reset polarity mismatch on async reset distribution

A flop's async reset disagrees with its source: a producer
flop drives a value the consumer never treats as assert, or a
port declaration contradicts the pin. The consumer never
enters reset when the source does. Add an inverter, or fix
the edge to match the declaration.

## RDC-003 (error) — Sync reset driven from a foreign async domain

A flop's synchronous reset fans in from a register in another
clock domain. The sync reset samples on the destination edge,
so a foreign source turns deassertion into a metastability
lottery. Synchronize the reset into the consumer domain.

## RDC-004 (error) — Async reset driven by combinational logic

A flop's async reset pin is a comb gate's output fed by flops.
Gate outputs glitch on near-simultaneous input changes, and on
an async reset pin the transient reads as a real assertion.
Register the gate on the consumer clock first.

## RDC-005 (warning) — Async reset from multiple independent sources

A flop's async reset combines two or more top-level ports with
no flop behind the gate. Independent board sources release at
independent times; the consumer's release edge is undefined.
Qualify the sources through one reset tree.

## RDC-006 (warning) — Muxed async reset without a local synchronizer

A flop's async reset is driven directly by a mux: selection
is explicit, but the selected leg still deasserts async to
the consumer clock. Pipe the mux through a 2FF reset
synchronizer in the consumer domain. Warning, not error:
the block may legitimately consume an upstream-synced reset.

## RDC-007 (error) — Reset synchronizer chain loads the asserted value

A reset synchronizer chain whose head D ties to the asserted
value never deasserts: on release it reloads assertion and
holds every downstream consumer in reset forever. Tie the
head D to the deasserted value: 1'b1 for active-low resets.

## RDC-008 (error) — Primary reset port unsynchronized in one domain

A top-level reset port fans straight into flops of a domain
with no reset synchronizer, while another domain syncs the
same port: the builder knew, then missed a domain. Sync the
port in every consuming domain. Silent when every domain
uses the raw port; that simplification is a separate review.

## RDC-009 (error) — Unqualified data crossing reset domains

A flop's data input is driven from another reset domain with
no shared release: the source can come out of reset while the
receiver samples. Both sides need an async reset to trip it;
a side with none never releases, so unreset storage fed from
a reset domain stays silent. Clocks do not matter here.

## RDC-010 (note) — Reset synchronizer chain record and checks

Every recognized reset synchronizer is recorded for review:
stages, clock, polarity, head constant, async root. Severity
follows what breaks: defects that destroy the shaped release
edge itself — wrong consumer clock, internal tap, gate on the
output — report at error, since the chain's contract fails no
matter what the consumer does. A consumer on the raw root in
a served domain reports at warn: it runs ahead of its synced
siblings, which corrupts only if the two sides interact.

## RDC-011 (error) — One net drives both sync and async resets

One resolved reset root reaches an async pin on some flop
and a sync control ($sdff SRST or a const-leg D-mux) on
another. Async users leave reset on the net's edge while
sync users wait for a clock, so the groups skew and their
handoff corrupts. Split the net or qualify one side.

