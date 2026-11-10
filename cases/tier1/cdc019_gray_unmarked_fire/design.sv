// A 3-bit gray counter is registered lane by lane and crossed apart
// with NO cdc_gray mark: the encoding is gray but unvouched, so the
// rule still fires. Must report CDC-019 on a source lane.
module cdc019_gray_unmarked_fire (
    input  logic ca,
    input  logic cb,
    output logic [2:0] q
);
    logic [2:0] bin;
    logic [2:0] gray;
    logic d0, d1, d2, m0, s0, m1, s1, m2, s2;
    always_ff @(posedge ca) bin <= bin + 1'b1;
    assign gray = bin ^ (bin >> 1);
    always_ff @(posedge ca) d0 <= gray[0];
    always_ff @(posedge ca) d1 <= gray[1];
    always_ff @(posedge ca) d2 <= gray[2];
    always_ff @(posedge cb) m0 <= d0;
    always_ff @(posedge cb) s0 <= m0;
    always_ff @(posedge cb) m1 <= d1;
    always_ff @(posedge cb) s1 <= m1;
    always_ff @(posedge cb) m2 <= d2;
    always_ff @(posedge cb) s2 <= m2;
    assign q = {s2, s1, s0};
endmodule
