// Two-bit source with mismatched tails: lane 0 through 2FF, lane 1
// through 3FF, to separate outputs. The skew is structural, not just
// metastability. Must report CDC-020 on the source register.
module cdc020_asymmetric_tails (
    input  logic ca,
    input  logic cb,
    input  logic [1:0] d,
    output logic q0,
    output logic q1
);
    logic [1:0] src_q;
    logic m0, s0, n0, n1, s1;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge cb) m0 <= src_q[0];
    always_ff @(posedge cb) s0 <= m0;
    always_ff @(posedge cb) n0 <= src_q[1];
    always_ff @(posedge cb) n1 <= n0;
    always_ff @(posedge cb) s1 <= n1;
    assign q0 = s0;
    assign q1 = s1;
endmodule
