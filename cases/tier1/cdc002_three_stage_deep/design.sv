// Three-deep chain: comfortable at the default bar, short once the
// site minimum rises to 4. Must report CDC-002 on the head with
// --sync-depth 4, and stay below the CDC-018 cascade threshold.
module cdc002_three_stage_deep (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic a;
    logic s1;
    logic s2;
    logic s3;
    always_ff @(posedge ca) a <= d;
    always_ff @(posedge cb) s1 <= a;
    always_ff @(posedge cb) s2 <= s1;
    always_ff @(posedge cb) s3 <= s2;
    assign q = s3;
endmodule
