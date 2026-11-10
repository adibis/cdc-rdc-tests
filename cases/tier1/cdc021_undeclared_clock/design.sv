// Toggle flop clocked by a port with no create_clock: the domain is
// invisible to every other check. Must report CDC-021 on the flop.
module cdc021_undeclared_clock (
    input  logic clkx,
    output logic q
);
    logic u;
    always_ff @(posedge clkx) u <= ~u;
    assign q = u;
endmodule
