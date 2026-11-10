// Mixed-sense port reset: rsta AND NOT rstb fans into one
// async reset pin with no flop behind the gate. Must report
// RDC-005 on the consumer.
module rdc005_inverted_leg (
    input  logic clk,
    input  logic rsta,
    input  logic rstb,
    input  logic d,
    output logic q
);
    logic rst_c;
    assign rst_c = rsta & ~rstb;
    always_ff @(posedge clk or posedge rst_c)
        if (rst_c) q <= 1'b0; else q <= d;
endmodule
