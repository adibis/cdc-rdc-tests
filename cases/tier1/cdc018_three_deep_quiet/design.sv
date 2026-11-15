// Three-deep chain: one stage under the default CDC-018 threshold
// of 4, at the default sync depth. The lower boundary of the
// policy: CDC-018 must stay silent, and nothing else fires.
module cdc018_three_deep_quiet (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic src_q, m1, m2, m3;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge cb) m1 <= src_q;
    always_ff @(posedge cb) m2 <= m1;
    always_ff @(posedge cb) m3 <= m2;
    assign q = m3;
endmodule
