// Event conservation across a toggle synchronizer, checked formally.
//
// Both clocks run off one global formal clock at the case's SDC
// ratio, with a free starting phase. After a settle phase with no
// events (which also flushes unknown start values from designs with
// no reset), every event accepted at the source must come out of the
// destination once the source has been quiet for a while. A cover
// proves events really flow end to end, so a vacuous run cannot pass.
//
// Reset, startup and traffic (docs/assumptions.md): the reset, if
// any, is held through the settle phase and never asserted again.
// State starts arbitrary and the settle phase flushes it. After it,
// events are unconstrained, or spaced 3 destination periods apart
// with SPACED; with P_RDY only events offered while ready count.
//
// Defines, set by scripts/formal-check.py from formal/cases.json:
//   DUT, SRC_HALF, DST_HALF  module and half-periods in formal steps
//   P_SRC, P_DST, P_EV, P_OUT port names; P_RST if the design has a reset
//   P_RDY                   ready output: only events offered while it is
//                           high are accepted (backpressure)
//   EV_LOW                  the event port is active low (a stall)
//   PULSE                   the output pulses per event (else it toggles)
//   SPACED                  events at least 3 destination periods apart
module fv_top (input logic ev);
    (* gclk *) logic gclk;

    logic src_clk = 0, dst_clk = 0;
    logic [7:0] src_ph = 0, dst_ph = 0;
    (* anyconst *) logic [7:0] dst_off;
    always @* assume (dst_off < `DST_HALF);
    always @(posedge gclk) begin
        src_ph <= (src_ph == `SRC_HALF - 1) ? 0 : src_ph + 1;
        if (src_ph == `SRC_HALF - 1) src_clk <= !src_clk;
        dst_ph <= (dst_ph == `DST_HALF - 1) ? 0 : dst_ph + 1;
        if (dst_ph == dst_off) dst_clk <= !dst_clk;
    end

    // Settle: reset asserted (if any) and no events for 5 dst periods.
    logic [9:0] t = 0;
    always @(posedge gclk) if (t != 10'h3ff) t <= t + 1;
    logic run;
    assign run = t > 10 * `DST_HALF;
    always @* if (!run) assume (!ev);

    logic out;
`ifdef P_RDY
    logic rdy;
`endif
`ifdef EV_LOW
    wire ev_port = !ev;
`else
    wire ev_port = ev;
`endif
    `DUT dut (
        .`P_SRC(src_clk), .`P_DST(dst_clk),
`ifdef P_RST
        .`P_RST(run),
`endif
`ifdef P_RDY
        .`P_RDY(rdy),
`endif
        .`P_EV(ev_port), .`P_OUT(out)
    );
`ifdef P_RDY
    wire accept = ev && rdy;
`else
    wire accept = ev;
`endif

    // Source side: count accepted events, as the design sees them.
    logic [7:0] in_cnt = 0, since = 8'hff;
    always @(posedge src_clk)
        if (run && accept) begin
            in_cnt <= in_cnt + 1;
            since <= 0;
        end else if (since != 8'hff) since <= since + 1;
`ifdef SPACED
    always @* if (ev) assume (since >= 3 * `DST_HALF / `SRC_HALF);
`endif

    // Destination side: count events seen, as a downstream flop would.
    logic [7:0] out_cnt = 0;
    logic last;
    always @(posedge dst_clk) begin
        last <= out;
`ifdef PULSE
        if (run && out) out_cnt <= out_cnt + 1;
`else
        if (run && out != last) out_cnt <= out_cnt + 1;
`endif
    end

    // Quiet: destination rising edges since in_cnt last changed.
    logic [3:0] quiet = 0;
    logic [7:0] in_prev = 0;
    logic dst_prev = 0;
    always @(posedge gclk) begin
        in_prev <= in_cnt;
        dst_prev <= dst_clk;
        if (in_cnt != in_prev) quiet <= 0;
        else if (dst_clk && !dst_prev && quiet != 4'hf) quiet <= quiet + 1;
    end

    wire settled = run && quiet >= 5 && in_cnt == in_prev;
    always @* if (settled) assert (in_cnt == out_cnt);
    always @* cover (settled && out_cnt >= 3);
endmodule
