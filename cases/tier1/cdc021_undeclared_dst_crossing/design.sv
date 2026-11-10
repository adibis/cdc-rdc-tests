// Crossing into an undeclared domain: a ca flop feeds a 2-deep chain
// on clkx, which has no create_clock. The crossing itself stays blind
// to every async check; CDC-021 reports one representative consumer.
module cdc021_undeclared_dst_crossing (
    input  logic ca,
    input  logic clkx,
    input  logic d,
    output logic q
);
    logic a, u1, u2;
    always_ff @(posedge ca) a <= d;
    always_ff @(posedge clkx) u1 <= a;
    always_ff @(posedge clkx) u2 <= u1;
    assign q = u2;
endmodule
