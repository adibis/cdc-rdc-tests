// Foreign ports feeding a chain through logic alone: p1 and p2
// are typed to ca but combine into a cb synchronizer with no
// registering flop. Must report CDC-006 on the first stage.
module cdc006_comb_source (
    input  logic ca,
    input  logic cb,
    input  logic p1,
    input  logic p2,
    output logic q
);
    logic w;
    logic s1;
    assign w = p1 & p2;
    always_ff @(posedge cb) s1 <= w;
    always_ff @(posedge cb) q <= s1;
endmodule
