// Transparent latch between domains: while the enable holds, the
// foreign signal flows straight through. Must report CDC-017 on it.
module cdc017_latch_in_path (
    input  logic ca,
    input  logic cb,
    input  logic d,
    input  logic en,
    output logic q
);
    logic src_q, lat, dst_q;
    always_ff @(posedge ca) src_q <= d;
    always_latch if (en) lat = src_q;
    always_ff @(posedge cb) dst_q <= lat;
    assign q = dst_q;
endmodule
