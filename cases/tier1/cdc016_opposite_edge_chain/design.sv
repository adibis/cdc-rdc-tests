// Chain stages on opposite edges of one clock: resolution time
// halves versus a same-edge chain. Must report CDC-016 on the head.
module cdc016_opposite_edge_chain (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic src_q, s1, s2;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge cb) s1 <= src_q;
    always_ff @(negedge cb) s2 <= s1;
    assign q = s2;
endmodule
