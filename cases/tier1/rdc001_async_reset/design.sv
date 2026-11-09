// Async reset released by a register in a foreign domain: the
// clk_b flop's reset deasserts on clk_a timing and races the
// local clock. Must report RDC-001 on the consumer.
module rdc001_async_reset (
    input  logic clk_a,
    input  logic clk_b,
    input  logic d,
    input  logic rst_in,
    output logic q
);
    logic r_q;
    always_ff @(posedge clk_a) r_q <= rst_in;
    always_ff @(posedge clk_b or posedge r_q)
        if (r_q) q <= 1'b0;
        else     q <= d;
endmodule
