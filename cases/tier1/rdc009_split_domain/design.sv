// Split reset domains: src on ra feeds dst on rb with no shared
// release. Must report RDC-009 on the destination.
module rdc009_split_domain (
    input  logic clk,
    input  logic ra,
    input  logic rb,
    input  logic d,
    output logic q
);
    logic src_q;
    always_ff @(posedge clk or posedge ra)
        if (ra) src_q <= 1'b0; else src_q <= d;
    always_ff @(posedge clk or posedge rb)
        if (rb) q <= 1'b0; else q <= src_q;
endmodule
