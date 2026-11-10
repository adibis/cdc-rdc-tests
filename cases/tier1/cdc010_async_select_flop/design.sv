// Clock mux selected from a third async domain: enf lives in
// cc while the mux gates ca and cb. Must report CDC-010 on
// the mux; the data crossing adds one CDC-026 leg-pair note.
module cdc010_async_select_flop (
    input  logic ca,
    input  logic cb,
    input  logic cc,
    input  logic en_d,
    input  logic d,
    output logic q
);
    logic sel;
    logic gclk;
    logic src;
    logic f;
    always_ff @(posedge cc) sel <= en_d;
    assign gclk = sel ? ca : cb;
    always_ff @(posedge ca) src <= d;
    always_ff @(posedge gclk) f <= src;
    always_ff @(posedge gclk) q <= f;
endmodule
