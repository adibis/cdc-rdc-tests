// Clock mux with a port select typed to ca, one of the muxed
// clocks. A plain mux still switches between asynchronous clocks,
// so a switch can land mid-phase on cb: a runt pulse. Must report
// CDC-010. Data is constant so no crossing adds findings.
module cdc010_shared_select_runt (
    input  logic ca,
    input  logic cb,
    input  logic sel,
    output logic q
);
    logic gclk;
    assign gclk = sel ? ca : cb;
    always_ff @(posedge gclk) q <= 1'b1;
endmodule
