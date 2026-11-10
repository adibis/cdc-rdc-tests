// Declared polarity mismatch: rst_n declares active-high but
// the flop consumes it active-low. Must report RDC-002.
module rdc002_port_mismatch (
    input  logic clk,
    (* reset_polarity = "high" *) input logic rst_n,
    output logic q
);
    always_ff @(posedge clk or negedge rst_n)
        if (!rst_n) q <= 1'b0; else q <= q;
endmodule
