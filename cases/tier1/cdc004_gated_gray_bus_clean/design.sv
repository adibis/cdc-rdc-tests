// Gray-coded bus behind a synced enable mux: gating clears CDC-004
// and the gray source clears CDC-012. Must stay silent.
module cdc004_gated_gray_bus_clean (
    input  logic ca,
    input  logic cb,
    input  logic [1:0] d,
    input  logic go,
    output logic [1:0] q
);
    logic [1:0] bin_q, gray, src_q, dst_q;
    logic go_q;
    always_ff @(posedge ca) bin_q <= d;
    assign gray = bin_q ^ {1'b0, bin_q[1]};
    always_ff @(posedge ca) src_q <= gray;
    always_ff @(posedge cb) go_q <= go;
    always_ff @(posedge cb) if (go_q) dst_q <= src_q;
    assign q = dst_q;
endmodule
