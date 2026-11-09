// Single-flop async crossing: clk_a launches, clk_b captures,
// no synchronizer. Any CDC checker must report CDC-001 here.
module cdc001_async_data (
    input  logic clk_a,
    input  logic clk_b,
    input  logic d,
    output logic q
);
    logic a;
    always_ff @(posedge clk_a) a <= d;
    always_ff @(posedge clk_b) q <= a;
endmodule
