// Two-port OR reset: two independent top ports ORed into an
// async reset pin with no flop behind the gate. Must report
// RDC-005 on the consumer.
module rdc005_or_ports (
    input  logic clk,
    input  logic rsta,
    input  logic rstb,
    input  logic d,
    output logic q
);
    logic rst_c;
    assign rst_c = rsta | rstb;
    always_ff @(posedge clk or posedge rst_c)
        if (rst_c) q <= 1'b0; else q <= d;
endmodule
