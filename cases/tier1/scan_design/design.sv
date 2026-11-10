// Three crossings share one test enable: a muxed clock, a muxed
// reset, and a plain async pair. Six findings name every leg:
// three data crossings, the clock-mux select, the multiclock
// receiver, and the muxed reset. The scan_en attribute is a
// hint only; the crossings are real with or without it.
module scan_ignored (
    input  logic clk_a,
    input  logic clk_b,
    input  logic scan_clk,
    (* scan_en *) input logic scan_en,
    input  logic raw_rst_n,
    input  logic d_gated,
    input  logic d_rmux,
    input  logic d_clean,
    output logic q_gated,
    output logic q_rmux,
    output logic q_clean
);

    logic gclk;
    assign gclk = scan_en ? scan_clk : clk_b;

    logic a_g;
    always_ff @(posedge clk_a) a_g <= d_gated;
    always_ff @(posedge gclk) q_gated <= a_g;

    logic muxed_rst_n;
    assign muxed_rst_n = scan_en ? 1'b1 : raw_rst_n;

    logic a_r;
    always_ff @(posedge clk_a) a_r <= d_rmux;
    always_ff @(posedge clk_b or negedge muxed_rst_n)
        if (!muxed_rst_n) q_rmux <= 1'b0;
        else              q_rmux <= a_r;

    logic a_c;
    always_ff @(posedge clk_a) a_c <= d_clean;
    always_ff @(posedge clk_b) q_clean <= a_c;

endmodule
