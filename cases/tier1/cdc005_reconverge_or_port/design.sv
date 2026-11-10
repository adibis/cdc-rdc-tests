// Twin 2FF chains recombine through an OR straight to the output
// port, with no capture flop: the shared OR cell is the proof of
// recombination. Must report CDC-005 and CDC-024 at the source.
module cdc005_reconverge_or_port (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic a;
    logic a1;
    logic a2;
    logic b1;
    logic b2;
    always_ff @(posedge ca) a <= d;
    always_ff @(posedge cb) a1 <= a;
    always_ff @(posedge cb) a2 <= a1;
    always_ff @(posedge cb) b1 <= a;
    always_ff @(posedge cb) b2 <= b1;
    assign q = a2 | b2;
endmodule
