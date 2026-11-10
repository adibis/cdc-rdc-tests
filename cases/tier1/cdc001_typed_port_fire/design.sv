// Typed async input captured directly: no launch flop, so the
// port itself (SDC-typed to ca) feeds a cb flop across async
// groups. CDC-001 must fire naming the port as the source.
module cdc001_typed_port_fire (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    always_ff @(posedge cb) q <= d;
endmodule
