// Untyped input on a sync-reset select: r has no input delay
// and reaches D through the reset mux. Must report CDC-011
// on the capture flop, and nothing else.
module cdc011_sync_reset (
    input  logic clk,
    input  logic d,
    input  logic r,
    output logic q
);
    always_ff @(posedge clk) if (r) q <= 1'b0; else q <= d;
endmodule
