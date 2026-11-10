// Foreign-released sync chain: a ca register releases the
// async reset of a two-flop cb chain while the chain's own
// data crosses ca->cb. Must report CDC-015 and RDC-001.
module rdc001_foreign_chain (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic src_q, rst_q, s1_q;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge ca) rst_q <= d;
    always_ff @(posedge cb or posedge rst_q) begin
        if (rst_q) begin s1_q <= 1'b0; q <= 1'b0; end
        else begin s1_q <= src_q; q <= s1_q; end
    end
endmodule
