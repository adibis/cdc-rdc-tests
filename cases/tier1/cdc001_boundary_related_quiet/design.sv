// Boundary control: the same ca flop drives output port q, typed
// to virtual clock virt, but the SDC declares no clock groups, so
// ca and virt are related clocks and the boundary path is timed.
// CDC-001 must stay silent.
module cdc001_boundary_related_quiet (
    input  logic ca,
    input  logic d,
    output logic q
);
    always_ff @(posedge ca) q <= d;
endmodule
