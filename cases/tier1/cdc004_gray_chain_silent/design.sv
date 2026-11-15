// Gray-coded bus into a multi-bit chain: a binary counter that
// steps by one from reset encodes to gray before crossing, so the
// bus changes one bit per source clock, and s1/q form a 2-deep
// chain. Must clear CDC-004 and stay silent.
module cdc004_gray_chain_silent (
    input  logic ca,
    input  logic cb,
    input  logic rst,
    output logic [1:0] q
);
    logic [1:0] bin;
    logic [1:0] gray;
    logic [1:0] greg;
    logic [1:0] s1;
    always_ff @(posedge ca) bin <= rst ? 2'd0 : bin + 2'd1;
    assign gray = bin ^ {1'b0, bin[1]};
    always_ff @(posedge ca) greg <= rst ? 2'd0 : gray;
    always_ff @(posedge cb) s1 <= greg;
    always_ff @(posedge cb) q <= s1;
endmodule
