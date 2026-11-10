// Untyped input fanning to two domains: d has no input delay
// and reaches a flop in each async group. Must error CDC-011
// once (one finding per port), and nothing else.
module cdc011_untyped_err (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic qa,
    output logic qb
);
    always_ff @(posedge ca) qa <= d;
    always_ff @(posedge cb) qb <= d;
endmodule
