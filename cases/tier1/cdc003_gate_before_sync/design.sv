// Two source flops combine through an AND gate before one shared
// 2FF synchronizer: each source-to-sync path fires CDC-003 (not
// CDC-001), so the head stage reports twice, once per source.
module cdc003_gate_before_sync (
    input  logic ca,
    input  logic cb,
    input  logic d1,
    input  logic d2,
    output logic q
);
    logic p;
    logic r;
    logic m;
    logic s1;
    logic s2;
    always_ff @(posedge ca) p <= d1;
    always_ff @(posedge ca) r <= d2;
    assign m = p & r;
    always_ff @(posedge cb) s1 <= m;
    always_ff @(posedge cb) s2 <= s1;
    assign q = s2;
endmodule
