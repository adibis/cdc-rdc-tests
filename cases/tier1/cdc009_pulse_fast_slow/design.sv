// Edge detector into a slow domain: pulse is one fc cycle wide
// and crosses to sc, over 1.5x slower. Must warn CDC-009 on
// the pulse flop (the source), and nothing else.
module cdc009_pulse_fast_slow (
    input  logic fc,
    input  logic sc,
    input  logic stim,
    output logic q
);
    logic req;
    logic reqd;
    logic pulse;
    logic s1;
    always_ff @(posedge fc) req <= stim;
    always_ff @(posedge fc) reqd <= req;
    always_ff @(posedge fc) pulse <= req & ~reqd;
    always_ff @(posedge sc) s1 <= pulse;
    always_ff @(posedge sc) q <= s1;
endmodule
