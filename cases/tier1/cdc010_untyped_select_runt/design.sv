// Clock mux with an untyped port select: sel has no input delay,
// so CDC-025 warns on the load. The select's domain does not
// matter to the switch itself: a plain mux between asynchronous
// clocks can emit a runt pulse, so CDC-010 reports too.
module cdc010_untyped_select_runt (
    input  logic ca,
    input  logic cb,
    input  logic sel,
    output logic q
);
    logic gclk;
    assign gclk = sel ? ca : cb;
    always_ff @(posedge gclk) q <= 1'b1;
endmodule
