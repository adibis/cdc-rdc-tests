// Flop-root dual use: r_q drives the async reset of aflop
// and the sync reset of sflop. Must report RDC-011 on the
// async user.
module rdc011_flop_root_dual (
    input  logic clk,
    input  logic kill,
    input  logic d,
    output logic q
);
    logic r_q, a_q;
    always_ff @(posedge clk)
        r_q <= kill;
    always_ff @(posedge clk or posedge r_q)
        if (r_q) a_q <= 1'b0; else a_q <= d;
    always_ff @(posedge clk)
        if (r_q) q <= 1'b0; else q <= a_q;
endmodule
