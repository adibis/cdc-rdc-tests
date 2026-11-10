// Clock mux with a port select from a third async domain:
// sel is typed to virtual clock cc while the mux gates ca
// and cb. Must report CDC-010 on the mux; the data crossing
// adds CDC-026 leg-pair notes.
module cdc010_async_select_port (
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
