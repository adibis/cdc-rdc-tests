// Five-deep chain: one stage past the default CDC-018 threshold of
// 4. Must report CDC-018 once, on the chain head, not per stage.
module cdc018_five_deep (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic src_q, m1, m2, m3, m4, m5;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge cb) m1 <= src_q;
    always_ff @(posedge cb) m2 <= m1;
    always_ff @(posedge cb) m3 <= m2;
    always_ff @(posedge cb) m4 <= m3;
    always_ff @(posedge cb) m5 <= m4;
    assign q = m5;
endmodule
