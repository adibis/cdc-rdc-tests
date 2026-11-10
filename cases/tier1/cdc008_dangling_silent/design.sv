// Dangling transparent chain on a clock: inversions buffer clk
// toward an output tap with no data load. Nothing samples the
// clock as data, so CDC-008 must stay silent.
module cdc008_dangling_silent (
    input  logic clk,
    input  logic d,
    output logic q,
    output logic tap
);
    logic b1;
    logic b2;
    assign b1 = ~clk;
    assign b2 = ~b1;
    assign tap = b2;
    always_ff @(posedge clk) q <= d;
endmodule
