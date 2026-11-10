// Foreign reset mux: a ca register selects a const-leg mux
// feeding a cb flop D. Must report CDC-001 and RDC-003.
module rdc003_foreign_mux (
    input  logic ca,
    input  logic cb,
    input  logic kill,
    input  logic d,
    output logic q
);
    logic src_q, mux_y;
    always_ff @(posedge ca) src_q <= kill;
    assign mux_y = src_q ? d : 1'b0;
    always_ff @(posedge cb) q <= mux_y;
endmodule
