// Stuck chain, three stages: active-low chain whose head D
// ties to 0 (asserted) so it never deasserts. Must report
// RDC-007 plus the RDC-010 record note, both on the tail.
module rdc007_three_stage_stuck (
    input  logic clk,
    input  logic rst,
    output logic q
);
    logic s0_q, s1_q;
    always_ff @(posedge clk or negedge rst)
        if (!rst) s0_q <= 1'b0; else s0_q <= 1'b0;
    always_ff @(posedge clk or negedge rst)
        if (!rst) s1_q <= 1'b0; else s1_q <= s0_q;
    always_ff @(posedge clk or negedge rst)
        if (!rst) q <= 1'b0; else q <= s1_q;
endmodule
