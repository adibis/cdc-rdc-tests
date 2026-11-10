// Two chains, split roots: src sits on a tail off ra while
// dst sits on a tail off rb, so neither release orders the
// other. Must report RDC-009 on dst plus two RDC-010 notes.
module rdc009_two_chains_split_roots (
    input  logic clk,
    input  logic ra,
    input  logic rb,
    input  logic d,
    output logic q
);
    logic ahead_q, atail_q, bhead_q, btail_q, src_q;
    always_ff @(posedge clk or posedge ra)
        if (ra) ahead_q <= 1'b1; else ahead_q <= 1'b0;
    always_ff @(posedge clk or posedge ra)
        if (ra) atail_q <= 1'b1; else atail_q <= ahead_q;
    always_ff @(posedge clk or posedge rb)
        if (rb) bhead_q <= 1'b1; else bhead_q <= 1'b0;
    always_ff @(posedge clk or posedge rb)
        if (rb) btail_q <= 1'b1; else btail_q <= bhead_q;
    always_ff @(posedge clk or posedge atail_q)
        if (atail_q) src_q <= 1'b0; else src_q <= d;
    always_ff @(posedge clk or posedge btail_q)
        if (btail_q) q <= 1'b0; else q <= src_q;
endmodule
