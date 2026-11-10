// Clock mux with a port select sharing a gated clock: sel is
// typed to ca, one of the muxed clocks. The select is safe, so
// CDC-010 must stay silent. Data is constant by design so no
// crossing adds findings.
module cdc010_shared_select_silent (
    input  logic ca,
    input  logic cb,
    input  logic sel,
    output logic q
);
    logic gclk;
    assign gclk = sel ? ca : cb;
    always_ff @(posedge gclk) q <= 1'b1;
endmodule
