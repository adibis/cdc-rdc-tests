// AND of two declared clocks drives a flop clock: the net glitches at
// no declared frequency. Must report CDC-023 on the gate and CDC-025
// on the domainless endpoint.
module cdc023_clock_combine (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic gclk;
    assign gclk = ca & cb;
    always_ff @(posedge gclk) q <= d;
endmodule
