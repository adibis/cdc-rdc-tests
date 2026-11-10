// One source flop fans out to twin 2FF chains with independent
// outputs and no recombination: CDC-024 fires on the fanout
// alone, at the source, with no CDC-005 beside it.
module cdc024_fanout_pair (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic qa,
    output logic qb
);
    logic a;
    logic a1;
    logic a2;
    logic b1;
    logic b2;
    always_ff @(posedge ca) a <= d;
    always_ff @(posedge cb) a1 <= a;
    always_ff @(posedge cb) a2 <= a1;
    always_ff @(posedge cb) b1 <= a;
    always_ff @(posedge cb) b2 <= b1;
    assign qa = a2;
    assign qb = b2;
endmodule
