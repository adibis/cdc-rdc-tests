# Locator contract

Every firing oracle pins one source line. Which endpoint that line
belongs to varies by rule: most rules report the destination, some
the source, chain rules a stage, grouped rules one representative.
This table states the contract per rule so a foreign checker maps
its own endpoints before comparing.

Single: one finding per offending endpoint. Grouped: one finding
covers several endpoints; the pinned line is the representative
and the message names the rest.

| rule | reports on | single/grouped |
|---|---|---|
| CDC-001 | capture flop (or port for boundary crossings) | single |
| CDC-002 | first sync stage of the short chain | single |
| CDC-003 | first sync stage behind the gate | single |
| CDC-004 | destination flop of the bare bus | single |
| CDC-005 | reconvergence source flop | single |
| CDC-006 | consumer flop with port-driven fanin | single |
| CDC-008 | terminal load cell sampling the clock | single |
| CDC-009 | pulse source flop | single |
| CDC-010 | clock-network cell (mux/gate) | single |
| CDC-011 | representative capture cell | grouped |
| CDC-012 | gated-bus source | single |
| CDC-013 | toggle source flop | single |
| CDC-014 | chain head stage | single |
| CDC-015 | first sync stage of the chain | single |
| CDC-016 | first sync stage of the mixed-edge chain | single |
| CDC-017 | latch cell | single |
| CDC-018 | chain head of the overlong chain | single |
| CDC-019 | name-sorted-first source flop | grouped |
| CDC-020 | sliced-bus source | single |
| CDC-021 | representative consumer (collection order) | grouped |
| CDC-022 | macro instance | single |
| CDC-023 | combine cell | single |
| CDC-024 | fanout source | single |
| CDC-025 | unresolved endpoint | single |
| CDC-026 | multiclock receiver | single |
| RDC-001 | representative consumer of the (source, clocks) group | grouped |
| RDC-002 | representative mismatched consumer | grouped |
| RDC-003 | name-sorted-first consumer | grouped |
| RDC-004 | consumer flop | single |
| RDC-005 | consumer flop | single |
| RDC-006 | consumer flop | single |
| RDC-007 | chain tail stage | single |
| RDC-008 | representative consumer missing the domain | grouped |
| RDC-009 | consumer flop | single |
| RDC-010 | record on chain tail; defects on consumer | both |
| RDC-011 | representative async-reset user | grouped |

"First" without qualification means first in sorted-name order
where the rule sorts (CDC-019, RDC-003) and first in discovery
order otherwise; only the pinned line is contractual, never the
ordering behind it.
