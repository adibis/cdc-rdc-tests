// Clock switching without runt pulses, checked formally.
//
// Both input clocks run free, but each holds every phase at least L
// formal steps. The muxed output must hold every phase at least L
// steps too, through any select change: a shorter phase is a runt
// pulse no downstream flop can be trusted with.
//
// Reset, startup and traffic (docs/assumptions.md): a warm-up holds
// both legs' resets and runs all clocks regularly, so synchronizers
// flush and the mux starts on clk0. After it, the control-domain
// select register may be written only once the previous switch has
// landed, as the design's `on` output reports. A glitch-free mux
// needs that assumption; a design that fails even under it is unsafe
// outright. A cover requires edges from clk1 and then clk0 after
// switching back, so a vacuous run cannot pass.
//
// Defines, set by scripts/formal-check.py: DUT. Every listed case
// has the same ports: clk0, clk1, rst0, rst1 (sync, active high, one
// per leg), cs and sel_d (the control domain and its select input),
// clk_out, on ({clk1 driving, clk0 driving}) and q.
module fv_top (input logic t0, input logic t1, input logic tc, input logic sel_free);
    (* gclk *) logic gclk;
    localparam int L = 3;

    logic [7:0] t = 0;
    always @(posedge gclk) if (t != 8'hff) t <= t + 1;
    logic warm;
    assign warm = t < 24;

    // A clock may toggle only after holding its phase L steps.
    logic clk0 = 0, clk1 = 0, cs = 0;
    logic [3:0] w0 = 0, w1 = 0;
    always @(posedge gclk) begin
        cs <= warm ? !cs : tc;
        if (warm ? w0 >= L : t0 && w0 >= L) begin
            clk0 <= !clk0;
            w0 <= 1;
        end else if (w0 != 4'hf) w0 <= w0 + 1;
        if (warm ? w1 >= L + 1 : t1 && w1 >= L) begin
            clk1 <= !clk1;
            w1 <= 1;
        end else if (w1 != 4'hf) w1 <= w1 + 1;
    end

    // Traffic: sel_d changes only once the design's select register
    // (mirrored as sel) holds it and `on` shows that leg driving.
    logic [1:0] on;
    logic sel_d = 0, sel = 0;
    always @(posedge cs) sel <= sel_d;
    logic settled;
    assign settled = sel_d == sel && on == (sel ? 2'b10 : 2'b01);
    always @(posedge gclk) if (!warm && settled) sel_d <= sel_free;

    logic clk_out;
    `DUT dut (
        .clk0, .clk1, .rst0(warm), .rst1(warm), .cs, .sel_d,
        .clk_out, .on, .q()
    );

    logic prev = 0;
    logic [3:0] wo = 0;
    always @(posedge gclk) begin
        prev <= clk_out;
        if (clk_out != prev) wo <= 1;
        else if (wo != 4'hf) wo <= wo + 1;
    end
    always @* if (t > 30 && clk_out != prev) assert (wo >= L);

    logic edge1 = 0, edge0 = 0;
    always @(posedge gclk) begin
        if (!warm && clk_out != prev && on == 2'b10) edge1 <= 1;
        if (edge1 && clk_out != prev && on == 2'b01) edge0 <= 1;
    end
    always @* cover (edge0);
endmodule
