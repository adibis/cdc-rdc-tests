# Waiver attributes

Eleven cases depend on synthesis attributes. Each is a promise the
designer makes and the checker takes at face value; the corpus pins
the exact spelling it uses so no checker has to guess.

All attributes attach to the signal declaration (`logic`, `input`,
`output`). Matching is case-sensitive except where noted. A foreign
checker implements these as waivers: when the promise holds for a
finding's endpoint, the finding drops. The honored-by lists
below match the reference checker's mark consumers exactly.
Silence oracles pin the net effect on real designs. The two
sections marked "not used in this corpus" specify spellings
no case pins yet.

## cdc_sync

`(* cdc_sync *)` — the signal is a vetted synchronizer output;
downstream crossings from it are synchronized by construction.
Aliases: `synchronizer`, `async_reg` (any case: `ASYNC_REG` matches).
Honored by: CDC-001, CDC-002, CDC-003, CDC-006, CDC-014, CDC-015,
CDC-016, CDC-017, CDC-018, CDC-019.

## cdc_static

`(* cdc_static *)` — the source never toggles in operation
(tie-offs, straps, quasi-static config). Aliases: `quasi_static`.
Honored by: CDC-001, CDC-002, CDC-003, CDC-004, CDC-019, CDC-020.

## cdc_handshake

`(* cdc_handshake *)` — the capture register closes a
request/acknowledge pair, so the crossing is sequenced, not
sampled. Alias: `req_ack_handshake`.
Honored by: CDC-001, CDC-012, CDC-013, CDC-014, CDC-020.

## cdc_gray

`(* cdc_gray *)` — the bus carries gray code: one lane moves per
transfer, so no snapshot can straddle two values. Alias:
`gray_code`. Always bare (no `= 1`).
Honored by: CDC-004, CDC-012, CDC-019, CDC-020.

## reset_polarity

`(* reset_polarity = "high" *)` or `(* reset_polarity = "low" *)`
on a reset input port — declares the port's active value. RDC-002
compares the declaration against the flop's reset-edge
sensitivity and fires on mismatch. Values are `high`/`low`,
matched case-insensitively; the corpus spells them lowercase.

## reset_sync, reset_synchronizer

Not used in this corpus. Where honored (RDC-002, RDC-004,
RDC-005, RDC-006, RDC-008), the mark vouches cells into the
synchronizer-member set those rules skip: a vetted reset
synchronizer whose consumers release cleanly needs no
per-finding waiver, since its members never report.

## glitchless_clock_mux (and aliases)

Not used in this corpus. On a clock-mux select it vouches a
glitch-free switchover; CDC-010 stays silent. Aliases:
`glitchless_mux`, `glitchfree_clock_mux`.

## scan_en

`(* scan_en *)` on the scan-enable port — marks scan-mode
plumbing for tools with a scan-waiver mode (icarium:
`--ignore-scan-mode`). The corpus runner never sets that
mode: scan-tagged crossings must still report, and the
`scan_design` oracle pins all six.
