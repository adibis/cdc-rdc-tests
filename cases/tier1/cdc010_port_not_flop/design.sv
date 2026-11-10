// Clock mux with a port select sharing a gated clock, with a
// real data crossing: sel is typed to ca. No wrong-domain
// verdict may fire; only CDC-026 leg-pair notes report.
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
