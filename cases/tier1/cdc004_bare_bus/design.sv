// Unprotected 2-bit bus crossing: no gating, no gray code.
// Must report CDC-004 once on the destination flop, never
// per lane.
module cdc004_bare_bus (
    input  logic ca,
    input  logic cb,
    input  logic [1:0] d,
    output logic [1:0] q
);
    logic [1:0] src;
    always_ff @(posedge ca) src <= d;
    always_ff @(posedge cb) q <= src;
endmodule
