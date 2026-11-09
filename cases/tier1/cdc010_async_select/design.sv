// Clock mux with a select from a third, unrelated domain: the
// select can transition while either clock input is high and
// chop the output. Must report CDC-010 on the mux.
module cdc010_async_select (
    input  logic clk_a,
    input  logic clk_b,
    input  logic clk_c,
    input  logic sel,
    output logic q
);
    logic gclk;
    assign gclk = sel ? clk_a : clk_b;
    always_ff @(posedge gclk) q <= 1'b1;
endmodule
