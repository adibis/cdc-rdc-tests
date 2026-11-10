// Mixed design: ca/cb are declared and async with a clean 2FF between
// them, but clkx drives two flops with no create_clock behind it. The
// declared half is quiet; CDC-021 reports one representative consumer.
module cdc021_undeclared_with_declared (
    input  logic ca,
    input  logic cb,
    input  logic clkx,
    input  logic d,
    output logic q,
    output logic uo
);
    logic a, s1, s2, u1, u2;
    always_ff @(posedge ca) a <= d;
    always_ff @(posedge cb) s1 <= a;
    always_ff @(posedge cb) s2 <= s1;
    always_ff @(posedge clkx) u1 <= ~u1;
    always_ff @(posedge clkx) u2 <= u1;
    assign q = s2;
    assign uo = u2;
endmodule
