// Two-flop synchronizer across async clocks: silent at the default
// --sync-depth 2. CDC-002 fires on this shape only when the bar is
// raised to 3; that run is config-gated, covered by the unit test.
module cdc002_two_stage_ok (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic a;
    logic s1;
    logic s2;
    always_ff @(posedge ca) a <= d;
    always_ff @(posedge cb) s1 <= a;
    always_ff @(posedge cb) s2 <= s1;
    assign q = s2;
endmodule
