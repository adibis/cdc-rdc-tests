// Four-deep chain whose head carries (* cdc_sync *): the designer
// vouches the depth is intentional, so the head abstains and
// CDC-018 must stay silent although the chain is at threshold.
module cdc018_marked_head_quiet (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic src_q, m2, m3, m4;
    (* cdc_sync *) logic m1;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge cb) m1 <= src_q;
    always_ff @(posedge cb) m2 <= m1;
    always_ff @(posedge cb) m3 <= m2;
    always_ff @(posedge cb) m4 <= m3;
    assign q = m4;
endmodule
