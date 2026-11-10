// Edge detector with swapped AND legs (inverted leg first) into a
// 5x slower domain: the shape matches either leg order. Must warn
// CDC-009 on the pulse flop, and nothing else.
module cdc009_swapped_legs (
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
    always_ff @(posedge fc) pulse <= ~reqd & req;
    always_ff @(posedge sc) s1 <= pulse;
    always_ff @(posedge sc) q <= s1;
endmodule
