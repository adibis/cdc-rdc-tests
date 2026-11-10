// Fast toggle into a slow domain with no XOR tail: two toggles
// between slow samples cancel to zero edges and events vanish.
// Must report CDC-013 on the toggle flop.
module cdc013_fast_toggle_no_xor (
    input  logic fc,
    input  logic sc,
    input  logic en,
    output logic q
);
    logic tog, m;
    always_ff @(posedge fc) if (en) tog <= ~tog;
    always_ff @(posedge sc) m <= tog;
    always_ff @(posedge sc) q <= m;
endmodule
