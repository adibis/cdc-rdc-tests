// Ordered release: dst reset derives from sync_q, a flop in the
// source reset domain, so dst wakes after src settles and
// RDC-009 stays silent. sync D follows src (not const) so the
// shape is derivation, not a second synchronizer. Clean case.
module rdc009_ordered_release (
    input  logic clk,
    input  logic rst,
    input  logic d,
    output logic q
);
    logic src_q, sync_q;
    always_ff @(posedge clk or posedge rst)
        if (rst) src_q <= 1'b0; else src_q <= d;
    always_ff @(posedge clk or posedge rst)
        if (rst) sync_q <= 1'b1; else sync_q <= src_q;
    always_ff @(posedge clk or posedge sync_q)
        if (sync_q) q <= 1'b0; else q <= src_q;
endmodule
