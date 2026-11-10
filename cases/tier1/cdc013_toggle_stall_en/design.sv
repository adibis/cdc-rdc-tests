// Toggle on an inverted stall enable into a 3FF dst chain: the
// $mux(Q,~Q) shape matches whatever the select is, and the extra
// stage still leaves paired toggles invisible. Must report CDC-013
// on the toggle flop, and nothing else.
module cdc013_toggle_stall_en (
    input  logic fc,
    input  logic sc,
    input  logic stall,
    output logic q
);
    logic tog, m1, m2;
    always_ff @(posedge fc) if (~stall) tog <= ~tog;
    always_ff @(posedge sc) m1 <= tog;
    always_ff @(posedge sc) m2 <= m1;
    always_ff @(posedge sc) q <= m2;
endmodule
