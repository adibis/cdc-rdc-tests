// Untyped async input captured directly: port d has no
// set_input_delay typing, so the crossing defers to CDC-011
// and CDC-001 must stay silent.
module cdc001_untyped_port_defers (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    always_ff @(posedge cb) q <= d;
endmodule
