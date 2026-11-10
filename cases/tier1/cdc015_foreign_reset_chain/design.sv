// Sync chain whose async reset is released by a flop in a foreign
// domain: the resolving flops never reach steady state. Must report
// CDC-015 on the chain head and RDC-001 on a consumer.
module cdc015_foreign_reset_chain (
    input  logic ca,
    input  logic cb,
    input  logic d,
    input  logic rst_in,
    output logic q
);
    logic src_q, rst_q, s1, s2;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge ca) rst_q <= rst_in;
    always_ff @(posedge cb or posedge rst_q) if (rst_q) s1 <= 1'b0; else s1 <= src_q;
    always_ff @(posedge cb or posedge rst_q) if (rst_q) s2 <= 1'b0; else s2 <= s1;
    assign q = s2;
endmodule
