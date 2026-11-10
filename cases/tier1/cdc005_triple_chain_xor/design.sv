// One source flop fans to three 2FF chains whose outputs join in an
// XOR tree before capture: every pair resolves apart and all three
// recombine. Must report CDC-005 and CDC-024 at the source.
module cdc005_triple_chain_xor (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic a;
    logic a1;
    logic a2;
    logic b1;
    logic b2;
    logic c1;
    logic c2;
    logic j;
    logic c;
    always_ff @(posedge ca) a <= d;
    always_ff @(posedge cb) a1 <= a;
    always_ff @(posedge cb) a2 <= a1;
    always_ff @(posedge cb) b1 <= a;
    always_ff @(posedge cb) b2 <= b1;
    always_ff @(posedge cb) c1 <= a;
    always_ff @(posedge cb) c2 <= c1;
    assign j = a2 ^ b2 ^ c2;
    always_ff @(posedge cb) c <= j;
    assign q = c;
endmodule
