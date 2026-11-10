// One 2-bit select mux fans to two source flops that cross apart:
// the lanes switch together upstream but resolve on their own
// schedules. Must report CDC-019 on a source lane.
module cdc019_mux_decode_apart (
    input  logic ca,
    input  logic cb,
    input  logic selm,
    input  logic [1:0] bus_a,
    input  logic [1:0] bus_b,
    output logic [1:0] q
);
    logic [1:0] dec;
    logic d0, d1, m0, s0, m1, s1;
    assign dec = selm ? bus_a : bus_b;
    always_ff @(posedge ca) d0 <= dec[0];
    always_ff @(posedge ca) d1 <= dec[1];
    always_ff @(posedge cb) m0 <= d0;
    always_ff @(posedge cb) s0 <= m0;
    always_ff @(posedge cb) m1 <= d1;
    always_ff @(posedge cb) s1 <= m1;
    assign q = {s1, s0};
endmodule
