// Dual use with both roles observable: rst is the async reset of
// qa and the sync reset of qs, each on its own output, so synthesis
// can remove neither. (A single flop cannot carry both: a sync
// branch under its own async condition is dead.) Must report
// RDC-011 on the async user.
module rdc011_async_and_sync_outputs (
    input  logic clk,
    input  logic rst,
    input  logic d,
    output logic qa,
    output logic qs
);
    always_ff @(posedge clk or posedge rst)
        if (rst) qa <= 1'b0;
        else qa <= d;
    always_ff @(posedge clk)
        if (rst) qs <= 1'b0;
        else qs <= d;
endmodule
