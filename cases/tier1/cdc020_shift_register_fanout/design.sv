// Four-bit serial-in shift register fanned lane by lane into four
// 2FF chains: every lane resolves apart and the word reassembles
// from mismatched cycles. Must report CDC-020 on the shift register.
module cdc020_shift_register_fanout (
    input  logic ca,
    input  logic cb,
    input  logic ser,
    output logic [3:0] q
);
    logic [3:0] sh;
    logic m0, s0, m1, s1, m2, s2, m3, s3;
    always_ff @(posedge ca) sh <= {sh[2:0], ser};
    always_ff @(posedge cb) m0 <= sh[0];
    always_ff @(posedge cb) s0 <= m0;
    always_ff @(posedge cb) m1 <= sh[1];
    always_ff @(posedge cb) s1 <= m1;
    always_ff @(posedge cb) m2 <= sh[2];
    always_ff @(posedge cb) s2 <= m2;
    always_ff @(posedge cb) m3 <= sh[3];
    always_ff @(posedge cb) s3 <= m3;
    assign q = {s3, s2, s1, s0};
endmodule
