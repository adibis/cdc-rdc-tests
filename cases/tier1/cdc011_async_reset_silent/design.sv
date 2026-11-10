// Async reset stays out of CDC-011: r is untyped but reaches
// only the ARST pin, never D. Must stay silent.
module cdc011_async_reset_silent (
    input  logic clk,
    input  logic d,
    input  logic r,
    output logic q
);
    always_ff @(posedge clk or posedge r) if (r) q <= 1'b0; else q <= d;
endmodule
