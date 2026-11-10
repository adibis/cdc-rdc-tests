// Held-constant source: the launch flop's output carries
// (* cdc_static *), asserting the source never toggles in
// operation. CDC-001 must stay silent.
module cdc001_static_src_quiet (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    (* cdc_static *) logic a;
    always_ff @(posedge ca) a <= d;
    always_ff @(posedge cb) q <= a;
endmodule
