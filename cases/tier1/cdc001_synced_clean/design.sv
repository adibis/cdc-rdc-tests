// Two-flop synchronizer: the canonical clean crossing. A CDC
// checker must stay silent on CDC-001 for q; anything else is
// a false positive against this seed.
module cdc001_synced_clean (
    input  logic clk_a,
    input  logic clk_b,
    input  logic d,
    output logic q
);
    logic a, s1;
    always_ff @(posedge clk_a) a <= d;
    always_ff @(posedge clk_b) s1 <= a;
    always_ff @(posedge clk_b) q <= s1;
endmodule
