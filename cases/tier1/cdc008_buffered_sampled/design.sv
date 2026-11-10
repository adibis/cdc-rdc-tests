// Buffered clock sampled as data: two inversions buffer clk and
// the buffered clock feeds the AND gate as data. Must report
// CDC-008 on the AND (the terminal load), and nothing else.
module cdc008_buffered_sampled (
    input  logic clk,
    input  logic d,
    output logic q
);
    logic b1;
    logic b2;
    logic spy;
    assign b1 = ~clk;
    assign b2 = ~b1;
    assign spy = b2 & d;
    always_ff @(posedge clk) q <= spy;
endmodule
