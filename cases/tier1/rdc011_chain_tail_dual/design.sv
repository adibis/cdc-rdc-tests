// Chain-tail dual use: a synced tail drives the async reset
// of one consumer and the sync reset of another. Must report
// RDC-011 plus the RDC-010 record note on the tail.
module rdc011_chain_tail_dual (
    input  logic clk,
    input  logic rst,
    input  logic d,
    output logic q
);
    logic head_q, tail_q, a_q;
    always_ff @(posedge clk or posedge rst)
        if (rst) head_q <= 1'b1; else head_q <= 1'b0;
    always_ff @(posedge clk or posedge rst)
        if (rst) tail_q <= 1'b1; else tail_q <= head_q;
    always_ff @(posedge clk or posedge tail_q)
        if (tail_q) a_q <= 1'b0; else a_q <= d;
    always_ff @(posedge clk)
        if (tail_q) q <= 1'b0; else q <= a_q;
endmodule
