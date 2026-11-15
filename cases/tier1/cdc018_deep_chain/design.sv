// Four-deep chain at the default CDC-018 threshold of 4 (depth >=
// threshold warns): two syncs of latency. Must report on the head.
module cdc018_deep_chain (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic src_q, m1, m2, m3, m4;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge cb) m1 <= src_q;
    always_ff @(posedge cb) m2 <= m1;
    always_ff @(posedge cb) m3 <= m2;
    always_ff @(posedge cb) m4 <= m3;
    assign q = m4;
endmodule
