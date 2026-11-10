// Three-port reset tree: (a AND b) OR c fans into one async
// reset pin with no flop behind either gate. Must report
// RDC-005 on the consumer.
module rdc005_three_port_tree (
    input  logic clk,
    input  logic rsta,
    input  logic rstb,
    input  logic rstc,
    input  logic d,
    output logic q
);
    logic t_ab, rst_c;
    assign t_ab = rsta & rstb;
    assign rst_c = t_ab | rstc;
    always_ff @(posedge clk or posedge rst_c)
        if (rst_c) q <= 1'b0; else q <= d;
endmodule
