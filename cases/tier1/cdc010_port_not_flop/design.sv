// Clock mux with a port select typed to ca, one of the muxed
// clocks, with a real data crossing. No wrong-domain verdict
// applies, but the plain mux still switches between asynchronous
// clocks, so CDC-010 reports the switch; CDC-026 notes the
// muxed-clock crossing.
module cdc010_port_not_flop (
    input  logic ca,
    input  logic cb,
    input  logic sel,
    input  logic d,
    output logic q
);
    logic gclk;
    logic src;
    logic f;
    assign gclk = sel ? ca : cb;
    always_ff @(posedge ca) src <= d;
    always_ff @(posedge gclk) f <= src;
    always_ff @(posedge gclk) q <= f;
endmodule
