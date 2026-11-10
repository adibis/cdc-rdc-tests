// Untyped input captured in one domain: d has no input delay.
// Must warn CDC-011 on the capture flop, and nothing else.
module cdc011_untyped_warn (
    input  logic clk,
    input  logic d,
    output logic q
);
    always_ff @(posedge clk) q <= d;
endmodule
