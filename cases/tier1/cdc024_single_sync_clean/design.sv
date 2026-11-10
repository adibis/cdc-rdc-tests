// One source into one sync chain: the canonical clean crossing.
// Must stay silent.
module cdc024_single_sync_clean (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic src_q, a1;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge cb) a1 <= src_q;
    always_ff @(posedge cb) q <= a1;
endmodule
