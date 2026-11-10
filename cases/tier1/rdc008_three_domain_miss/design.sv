// Missed domain across three clocks: port rst is synced in
// ca and cb but raw in cc, where two consumers take it
// direct. Must report RDC-008 plus one RDC-010 record note
// per chain tail.
module rdc008_three_domain_miss (
    input  logic ca,
    input  logic cb,
    input  logic cc,
    input  logic rst,
    input  logic da,
    input  logic db,
    input  logic dc,
    output logic qa,
    output logic qb,
    output logic qc
);
    logic ahead_q, atail_q, bhead_q, btail_q, c0_q;
    always_ff @(posedge ca or negedge rst)
        if (!rst) ahead_q <= 1'b0; else ahead_q <= 1'b1;
    always_ff @(posedge ca or negedge rst)
        if (!rst) atail_q <= 1'b0; else atail_q <= ahead_q;
    always_ff @(posedge ca or negedge atail_q)
        if (!atail_q) qa <= 1'b0; else qa <= da;
    always_ff @(posedge cb or negedge rst)
        if (!rst) bhead_q <= 1'b0; else bhead_q <= 1'b1;
    always_ff @(posedge cb or negedge rst)
        if (!rst) btail_q <= 1'b0; else btail_q <= bhead_q;
    always_ff @(posedge cb or negedge btail_q)
        if (!btail_q) qb <= 1'b0; else qb <= db;
    always_ff @(posedge cc or negedge rst) begin
        if (!rst) begin c0_q <= 1'b0; qc <= 1'b0; end
        else begin c0_q <= dc; qc <= c0_q; end
    end
endmodule
