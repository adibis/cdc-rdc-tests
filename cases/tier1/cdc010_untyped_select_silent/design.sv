// Clock mux with an untyped port select: sel has no input
// delay, so CDC-010 defers and CDC-025 warns on the load.
// Data is constant by design to isolate the select verdict.
module cdc010_untyped_select_silent (
    input  logic ca,
    input  logic cb,
    input  logic sel,
    output logic q
);
    logic gclk;
    assign gclk = sel ? ca : cb;
    always_ff @(posedge gclk) q <= 1'b1;
endmodule
