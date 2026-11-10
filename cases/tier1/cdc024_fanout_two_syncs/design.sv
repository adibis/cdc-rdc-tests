// One source bit fans to two independent sync chains that resolve on
// their own edges. Must report CDC-024 on the source.
module cdc024_fanout_two_syncs (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic qa,
    output logic qb
);
    logic src_q, a1, a2, b1, b2;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge cb) a1 <= src_q;
    always_ff @(posedge cb) a2 <= a1;
    always_ff @(posedge cb) b1 <= src_q;
    always_ff @(posedge cb) b2 <= b1;
    assign qa = a2;
    assign qb = b2;
endmodule
