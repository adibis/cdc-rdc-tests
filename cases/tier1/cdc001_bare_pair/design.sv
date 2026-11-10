// Bare async pair: a ca flop launches, a cb flop captures,
// with no synchronizer between them. CDC-001 must fire on
// the capture flop.
module cdc001_bare_pair (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic a;
    always_ff @(posedge ca) a <= d;
    always_ff @(posedge cb) q <= a;
endmodule
