// Flopped comb reset: an AND of two same-clock flops drives an
// async reset pin. Must report RDC-004 on the consumer.
module rdc004_comb_reset (
    input  logic clk,
    input  logic a,
    input  logic b,
    input  logic d,
    output logic q
);
    logic fa_q, fb_q, rst_c;
    always_ff @(posedge clk) fa_q <= a;
    always_ff @(posedge clk) fb_q <= b;
    assign rst_c = fa_q & fb_q;
    always_ff @(posedge clk or posedge rst_c)
        if (rst_c) q <= 1'b0; else q <= d;
endmodule
