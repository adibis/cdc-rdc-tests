// Fast toggle into a slow domain with NO async grouping: both
// clocks are declared but never grouped, yet the 2ns/20ns ratio
// alone decides. Must report CDC-013 on the toggle flop only.
module cdc013_toggle_sync_ratio (
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
