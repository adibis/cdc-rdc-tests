// Edge detector into a slow domain with NO async grouping: both
// clocks are declared but never grouped, yet the 2ns/10ns ratio
// alone decides. Must warn CDC-009 on the pulse flop, only it.
module cdc009_sync_clocks_fire (
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
