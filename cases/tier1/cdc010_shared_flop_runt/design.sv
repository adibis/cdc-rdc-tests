// Clock mux selected from a sharing domain: sel lives in cb, one
// of the muxed clocks. That rules out a wrong-domain select, but a
// plain mux still switches between asynchronous clocks, and a
// switch synchronous to cb lands mid-phase on ca: a runt pulse.
// Must report CDC-010. Data is constant so no crossing adds
// findings.
module cdc010_shared_flop_runt (
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
