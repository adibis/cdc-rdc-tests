// Mux-gated 2-bit bus with no handshake: the enable holds the
// mux but nothing holds the source payload. Must clear CDC-004
// and warn CDC-012 on the source register.
module cdc012_gated_bus (
    input  logic ca,
    input  logic cb,
    input  logic [1:0] d,
    input  logic go,
    output logic [1:0] q
);
    logic [1:0] src;
    logic en;
    always_ff @(posedge ca) src <= d;
    always_ff @(posedge cb) en <= go;
    always_ff @(posedge cb) q <= en ? src : q;
endmodule
