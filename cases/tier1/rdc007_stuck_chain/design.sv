// Stuck chain: active-low reset chain whose head D ties to 0
// (asserted) so it never deasserts. Must report RDC-007 plus
// the RDC-010 record note, both on the tail.
module rdc007_stuck_chain (
    input  logic clk,
    input  logic rst,
    output logic q
);
    logic head_q;
    always_ff @(posedge clk or negedge rst)
        if (!rst) head_q <= 1'b0; else head_q <= 1'b0;
    always_ff @(posedge clk or negedge rst)
        if (!rst) q <= 1'b0; else q <= head_q;
endmodule
