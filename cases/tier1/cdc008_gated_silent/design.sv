// AND-gated clock with a same-domain enable: the gate is clock
// distribution, never data use. CDC-008 must stay silent.
module cdc008_gated_silent (
    input  logic clk,
    input  logic en,
    input  logic d,
    output logic q
);
    logic gclk;
    assign gclk = clk & en;
    always_ff @(posedge gclk) q <= d;
endmodule
