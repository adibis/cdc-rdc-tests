// Foreign sync reset, if-spelling: a ca flop drives the sync
// reset branch of a cb flop, active-high resets both sides.
// Must report RDC-003 and CDC-001 on the consumer.
module rdc003_srst_if_direct (
    input  logic ca,
    input  logic cb,
    input  logic ra,
    input  logic rb,
    input  logic kill,
    input  logic d,
    output logic q
);
    logic src_q;
    always_ff @(posedge ca or posedge ra)
        if (ra) src_q <= 1'b0; else src_q <= kill;
    always_ff @(posedge cb or posedge rb)
        if (rb) q <= 1'b0;
        else if (src_q) q <= 1'b0;
        else q <= d;
endmodule
