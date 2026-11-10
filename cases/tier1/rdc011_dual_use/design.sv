// Dual-use net: rst drives an async pin on aflop and the sync
// reset of sflop, so the groups never leave reset together.
// Must report RDC-011 on the async user.
module rdc011_dual_use (
    input  logic clk,
    input  logic rst,
    input  logic d,
    output logic q
);
    logic a_q;
    always_ff @(posedge clk or posedge rst)
        if (rst) a_q <= 1'b0; else a_q <= d;
    always_ff @(posedge clk)
        if (rst) q <= 1'b0; else q <= a_q;
endmodule
