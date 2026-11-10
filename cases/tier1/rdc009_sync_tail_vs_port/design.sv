// Sync tail vs raw port: src takes reset from a chain tail
// off ra while dst takes raw rb, so the roots are disjoint.
// Must report RDC-009 on dst plus the RDC-010 record note.
module rdc009_sync_tail_vs_port (
    input  logic clk,
    input  logic ra,
    input  logic rb,
    input  logic d,
    output logic q
);
    logic head_q, tail_q, src_q;
    always_ff @(posedge clk or posedge ra)
        if (ra) head_q <= 1'b1; else head_q <= 1'b0;
    always_ff @(posedge clk or posedge ra)
        if (ra) tail_q <= 1'b1; else tail_q <= head_q;
    always_ff @(posedge clk or posedge tail_q)
        if (tail_q) src_q <= 1'b0; else src_q <= d;
    always_ff @(posedge clk or posedge rb)
        if (rb) q <= 1'b0; else q <= src_q;
endmodule
