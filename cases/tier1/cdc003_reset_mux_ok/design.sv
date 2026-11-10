// A lone reset mux on the synchronizer entry is part of the head
// flop, not combinational logic before it: the crossing stays
// silent (no CDC-003, no CDC-001).
module cdc003_reset_mux_ok (
    input  logic ca,
    input  logic cb,
    input  logic d,
    input  logic rst,
    output logic q
);
    logic a;
    logic m;
    logic s1;
    logic s2;
    always_ff @(posedge ca) a <= d;
    assign m = rst ? 1'b0 : a;
    always_ff @(posedge cb) s1 <= m;
    always_ff @(posedge cb) s2 <= s1;
    assign q = s2;
endmodule
