// Divided clock sampled as data: div toggles on clk and clocks q,
// but div also feeds the AND gate as data. Must report CDC-008
// on the AND (the terminal load), and nothing else.
module cdc008_divided_sampled (
    input  logic clk,
    input  logic d,
    output logic q
);
    logic div;
    logic spy;
    always_ff @(posedge clk) div <= ~div;
    assign spy = div & d;
    always_ff @(posedge div) q <= spy;
endmodule
