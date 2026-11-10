// One source flop fans out to twin 2FF chains whose outputs AND
// back together downstream: CDC-005 fires on the reconvergence
// and CDC-024 fires on the fanout itself, both at the source.
module cdc005_reconvergent_pair (
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
    logic j;
    logic c;
    always_ff @(posedge ca) a <= d;
    always_ff @(posedge cb) a1 <= a;
    always_ff @(posedge cb) a2 <= a1;
    always_ff @(posedge cb) b1 <= a;
    always_ff @(posedge cb) b2 <= b1;
    assign j = a2 & b2;
    always_ff @(posedge cb) c <= j;
    assign q = c;
endmodule
