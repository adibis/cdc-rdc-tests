// Stuck chain feeding a consumer: active-low chain whose
// head D ties to 0 (asserted) drives a consumer's async reset,
// so the consumer never leaves reset. Must report RDC-007
// plus the RDC-010 record note, both on the tail.
module rdc007_stuck_feeds_consumer (
    input  logic clk,
    input  logic rst,
    input  logic d,
    output logic q
);
    logic head_q, tail_q;
    always_ff @(posedge clk or negedge rst)
        if (!rst) head_q <= 1'b0; else head_q <= 1'b0;
    always_ff @(posedge clk or negedge rst)
        if (!rst) tail_q <= 1'b0; else tail_q <= head_q;
    always_ff @(posedge clk or negedge tail_q)
        if (!tail_q) q <= 1'b0; else q <= d;
endmodule
