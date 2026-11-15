// User-vouched gray source: src_q steps through the 2-bit gray
// sequence from reset by an explicit next-state table, which no
// structural check recognizes, so the cdc_gray promise is what
// clears the single-stage bus crossing. Must stay silent.
module cdc004_vouched_gray_silent (
    input  logic ca,
    input  logic cb,
    input  logic rst,
    output logic [1:0] q
);
    (* cdc_gray *) logic [1:0] src_q;
    always_ff @(posedge ca)
        if (rst) src_q <= 2'b00;
        else
            case (src_q)
                2'b00:   src_q <= 2'b01;
                2'b01:   src_q <= 2'b11;
                2'b11:   src_q <= 2'b10;
                default: src_q <= 2'b00;
            endcase
    always_ff @(posedge cb) q <= src_q;
endmodule
