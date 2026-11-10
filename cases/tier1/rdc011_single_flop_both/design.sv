// Single flop, both contracts: one flop takes rst as its
// async reset and keys its D-mux on the same net. Must
// report RDC-011.
module rdc011_single_flop_both (
    input  logic clk,
    input  logic rst,
    input  logic d,
    output logic q
);
    always_ff @(posedge clk or posedge rst)
        if (rst) q <= 1'b0;
        else q <= rst ? 1'b1 : d;
endmodule
