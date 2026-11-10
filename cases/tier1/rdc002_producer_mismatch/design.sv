// Producer value mismatch: prod releases at 0 but cons reads
// prod_q active-high, so cons never enters reset. prod D is a
// port (not const) so no incidental chain note fires.
module rdc002_producer_mismatch (
    input  logic clk,
    input  logic rst,
    input  logic d,
    output logic q
);
    logic prod_q;
    always_ff @(posedge clk or negedge rst)
        if (!rst) prod_q <= 1'b0; else prod_q <= d;
    always_ff @(posedge clk or posedge prod_q)
        if (prod_q) q <= 1'b0; else q <= 1'b1;
endmodule
