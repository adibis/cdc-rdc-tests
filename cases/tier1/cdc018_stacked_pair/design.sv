// One source flop feeds two independent 4-deep chains to separate
// outputs: a doubled fix, reported once per (source, clock) on the
// longest head. Must report CDC-018 once, plus CDC-024 at the source.
module cdc018_stacked_pair (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q0,
    output logic q1
);
    logic src_q;
    logic a1, a2, a3, a4;
    logic b1, b2, b3, b4;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge cb) a1 <= src_q;
    always_ff @(posedge cb) a2 <= a1;
    always_ff @(posedge cb) a3 <= a2;
    always_ff @(posedge cb) a4 <= a3;
    always_ff @(posedge cb) b1 <= src_q;
    always_ff @(posedge cb) b2 <= b1;
    always_ff @(posedge cb) b3 <= b2;
    always_ff @(posedge cb) b4 <= b3;
    assign q0 = a4;
    assign q1 = b4;
endmodule
