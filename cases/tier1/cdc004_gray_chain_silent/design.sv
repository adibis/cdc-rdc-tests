// Gray-coded bus into a multi-bit chain: binary bin encodes to
// gray before crossing, and s1/s2 form a 2-deep chain. Must
// clear CDC-004 and stay silent.
module cdc004_gray_chain_silent (
    input  logic ca,
    input  logic cb,
    input  logic [1:0] d,
    output logic [1:0] q
);
    logic [1:0] bin;
    logic [1:0] gray;
    logic [1:0] greg;
    logic [1:0] s1;
    always_ff @(posedge ca) bin <= d;
    assign gray = bin ^ {1'b0, bin[1]};
    always_ff @(posedge ca) greg <= gray;
    always_ff @(posedge cb) s1 <= greg;
    always_ff @(posedge cb) q <= s1;
endmodule
