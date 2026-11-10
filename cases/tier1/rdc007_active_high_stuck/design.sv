// Stuck chain, active-high: head D ties to 1 (asserted) so
// it never deasserts. Must report RDC-007 plus the RDC-010
// record note, both on the tail.
module rdc007_active_high_stuck (
    input  logic clk,
    input  logic rst,
    output logic q
);
    logic head_q;
    always_ff @(posedge clk or posedge rst)
        if (rst) head_q <= 1'b1; else head_q <= 1'b1;
    always_ff @(posedge clk or posedge rst)
        if (rst) q <= 1'b1; else q <= head_q;
endmodule
