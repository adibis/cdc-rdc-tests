// One shared decode fans to two source flops that cross apart: lanes
// change together upstream but resolve on their own schedules.
// Must report CDC-019 on a source lane.
module cdc019_shared_decode_apart (
    input  logic ca,
    input  logic cb,
    input  logic [1:0] sel_a,
    input  logic [1:0] sel_b,
    output logic [1:0] q
);
    logic [1:0] dec;
    logic d0, d1, m0, s0, m1, s1;
    always_ff @(posedge ca) d0 <= dec[0];
    always_ff @(posedge ca) d1 <= dec[1];
    assign dec = sel_a & sel_b;
    always_ff @(posedge cb) m0 <= d0;
    always_ff @(posedge cb) s0 <= m0;
    always_ff @(posedge cb) m1 <= d1;
    always_ff @(posedge cb) s1 <= m1;
    assign q = {s1, s0};
endmodule
