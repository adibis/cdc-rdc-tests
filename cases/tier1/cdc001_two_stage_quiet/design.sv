// Two-stage synchronizer: the ca launch feeds two back-to-back
// cb flops, so the crossing is synchronized and CDC-001 must
// stay silent.
module cdc001_two_stage_quiet (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic a, s1;
    always_ff @(posedge ca) a <= d;
    always_ff @(posedge cb) s1 <= a;
    always_ff @(posedge cb) q <= s1;
endmodule
