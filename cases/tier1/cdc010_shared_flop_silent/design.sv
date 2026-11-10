// Clock mux selected from a sharing domain: enf lives in cb,
// one of the muxed clocks. The select is safe, so CDC-010
// must stay silent. Data is constant by design so no crossing
// adds findings.
module cdc010_shared_flop_silent (
    input  logic ca,
    input  logic cb,
    input  logic en_d,
    output logic q
);
    logic sel;
    logic gclk;
    always_ff @(posedge cb) sel <= en_d;
    assign gclk = sel ? ca : cb;
    always_ff @(posedge gclk) q <= 1'b1;
endmodule
