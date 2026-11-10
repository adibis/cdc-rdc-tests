// Destination-clocked latch enable: the enable is registered in cb
// before gating the latch, but the data path still crosses domains
// through transparency. Must report CDC-017 on the latch.
module cdc017_latch_flop_enable (
    input  logic ca,
    input  logic cb,
    input  logic d,
    input  logic en_in,
    output logic q
);
    logic src_q, en_q, lat, dst_q;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge cb) en_q <= en_in;
    always_latch if (en_q) lat = src_q;
    always_ff @(posedge cb) dst_q <= lat;
    assign q = dst_q;
endmodule
