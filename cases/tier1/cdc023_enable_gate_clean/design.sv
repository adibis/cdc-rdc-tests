// AND of one clock with a same-domain enable: a gated clock, not a
// combine. Must stay silent.
module cdc023_enable_gate_clean (
    input  logic ca,
    input  logic en,
    input  logic d,
    output logic q
);
    logic gclk;
    assign gclk = ca & en;
    always_ff @(posedge gclk) q <= d;
endmodule
