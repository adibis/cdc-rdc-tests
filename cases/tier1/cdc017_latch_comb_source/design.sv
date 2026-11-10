// Masked latch path: an AND sits between the ca source flop and the
// latch D, but while the enable holds the foreign signal still flows
// straight through. Must report CDC-017 on the latch.
module cdc017_latch_comb_source (
    input  logic ca,
    input  logic cb,
    input  logic d,
    input  logic mask,
    input  logic en,
    output logic q
);
    logic src_q, lat, dst_q;
    always_ff @(posedge ca) src_q <= d;
    always_latch if (en) lat = src_q & mask;
    always_ff @(posedge cb) dst_q <= lat;
    assign q = dst_q;
endmodule
