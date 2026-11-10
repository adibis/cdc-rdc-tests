// User-vouched gray source: src_q carries a cdc_gray promise,
// so the single-stage bus crossing clears CDC-004 and stays
// silent.
module cdc004_vouched_gray_silent (
    input  logic ca,
    input  logic cb,
    input  logic [1:0] d,
    output logic [1:0] q
);
    (* cdc_gray = 1 *) logic [1:0] src_q;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge cb) q <= src_q;
endmodule
