// Same reset domain: src feeds dst under one shared reset, so
// release is ordered and RDC-009 stays silent. Clean case.
module rdc009_same_domain (
    input  logic clk,
    input  logic rst,
    input  logic d,
    output logic q
);
    logic src_q;
    always_ff @(posedge clk or posedge rst)
        if (rst) src_q <= 1'b0; else src_q <= d;
    always_ff @(posedge clk or posedge rst)
        if (rst) q <= 1'b0; else q <= src_q;
endmodule
