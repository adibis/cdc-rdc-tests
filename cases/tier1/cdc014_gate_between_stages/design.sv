// Gate between synchronizer stages: s1 fans through an AND into s2
// on the same clock, destroying the chain's resolution time.
// Must report CDC-014 on the chain head s1.
module cdc014_gate_between_stages (
    input  logic ca,
    input  logic cb,
    input  logic d,
    input  logic m,
    output logic q
);
    logic src_q, s1, mask_q, g, s2;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge cb) s1 <= src_q;
    always_ff @(posedge cb) mask_q <= m;
    assign g = s1 & mask_q;
    always_ff @(posedge cb) s2 <= g;
    assign q = s2;
endmodule
