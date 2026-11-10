// Boundary crossing: a ca flop drives output port q, which the
// SDC types to a foreign virtual clock. Nothing inside the
// block synchronizes it. CDC-001 must fire on port q.
module cdc001_boundary_fire (
    input  logic ca,
    input  logic d,
    output logic q
);
    always_ff @(posedge ca) q <= d;
endmodule
