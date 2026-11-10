// Chain tap: consumer qc takes async reset from the head stage
// of a reset chain instead of the tail. Must report the
// RDC-010 record note on the tail plus the tap err on qc.
module rdc010_chain_tap (
    input  logic clk,
    input  logic rst,
    input  logic d,
    output logic q
);
    logic s1_q, s2_q;
    always_ff @(posedge clk or posedge rst)
        if (rst) s1_q <= 1'b1; else s1_q <= 1'b0;
    always_ff @(posedge clk or posedge rst)
        if (rst) s2_q <= 1'b1; else s2_q <= s1_q;
    always_ff @(posedge clk or posedge s1_q)
        if (s1_q) q <= 1'b0; else q <= d;
endmodule
