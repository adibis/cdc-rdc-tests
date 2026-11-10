// Reversed opposite-edge chain: negedge head, posedge tail. Either
// order halves the resolution time. Must report CDC-016 on the head.
module cdc016_negedge_head (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic src_q, s1, s2;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(negedge cb) s1 <= src_q;
    always_ff @(posedge cb) s2 <= s1;
    assign q = s2;
endmodule
