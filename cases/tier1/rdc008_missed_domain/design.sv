// Missed domain: port rst is synced in ca but raw in cb, where
// two consumers take it direct. Must report RDC-008 plus the
// RDC-010 record note on the ca chain tail.
module rdc008_missed_domain (
    input  logic ca,
    input  logic cb,
    input  logic rst,
    input  logic da,
    input  logic db,
    output logic qa,
    output logic qb
);
    logic ahead_q, atail_q, b0_q;
    always_ff @(posedge ca or negedge rst)
        if (!rst) ahead_q <= 1'b0; else ahead_q <= 1'b1;
    always_ff @(posedge ca or negedge rst)
        if (!rst) atail_q <= 1'b0; else atail_q <= ahead_q;
    always_ff @(posedge ca or negedge atail_q)
        if (!atail_q) qa <= 1'b0; else qa <= da;
    always_ff @(posedge cb or negedge rst) begin
        if (!rst) begin b0_q <= 1'b0; qb <= 1'b0; end
        else begin b0_q <= db; qb <= b0_q; end
    end
endmodule
