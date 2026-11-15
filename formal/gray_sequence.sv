// Gray sequence across a crossing, checked formally.
//
// A case whose verdict rests on gray coding claims more than an XOR
// in the source: the crossing value must step through reflected gray
// order, one bit at a time. Gray-encoding an arbitrary input does not
// do that (binary 2'b00 -> 2'b10 is gray 2'b00 -> 2'b11). After a
// warm-up that holds the source in reset and flushes unknown start
// values, every change of the output must be the gray successor of
// the value before it. The first change after warm-up is exempt: it
// replaces a destination value that had no reset. A cover requires a
// full wrap of the sequence, so a vacuous run cannot pass. The check
// is bounded: a pass means no out-of-order change within the depth
// formal-check.py sets.
//
// Reset, startup and traffic (docs/assumptions.md): the source reset
// is held through warm-up and never asserted again. State starts
// arbitrary; warm-up and the exempt first change cover it. The
// source has no data inputs, except P_IN, which is driven freely.
//
// Defines, set by scripts/formal-check.py from formal/cases.json:
//   DUT, W                    module and output width
//   P_SRC, P_DST, P_RST, P_OUT port names; P_RST is a sync active-high
//                             source-domain reset
//   P_IN                      optional data input, driven freely
//   FREE                      after warm-up both clocks run free, so a
//                             handshake must deliver every value under
//                             any phase; otherwise both clocks are one
//                             clock and the output replays the source
module fv_top (input logic src_free, input logic dst_free, input logic [`W-1:0] din);
    (* gclk *) logic gclk;

    logic [7:0] t = 0;
    always @(posedge gclk) if (t != 8'hff) t <= t + 1;
    logic warm;
    assign warm = t < 16;

    logic src_clk = 0;
`ifdef FREE
    logic dst_clk = 0;
    always @(posedge gclk) begin
        src_clk <= warm ? !src_clk : src_free;
        dst_clk <= warm ? !dst_clk : dst_free;
    end
`else
    logic dst_clk;
    assign dst_clk = src_clk;
    always @(posedge gclk) src_clk <= !src_clk;
`endif

    logic [`W-1:0] q;
    `DUT dut (
        .`P_SRC(src_clk), .`P_DST(dst_clk), .`P_RST(warm),
`ifdef P_IN
        .`P_IN(din),
`endif
        .`P_OUT(q)
    );

    function automatic logic [`W-1:0] succ(input logic [`W-1:0] g);
        logic [`W-1:0] b;
        b[`W-1] = g[`W-1];
        for (int i = `W - 2; i >= 0; i--) b[i] = b[i+1] ^ g[i];
        b = b + 1'b1;
        succ = b ^ (b >> 1);
    endfunction

    logic [`W-1:0] q_d;
    logic [7:0] changes = 0;
    logic step;
    assign step = !warm && q != q_d;
    always @(posedge gclk) begin
        q_d <= q;
        if (step && changes != 8'hff) changes <= changes + 1;
    end

    always @* if (step && changes != 0) assert (q == succ(q_d));
    always @* cover (changes >= (1 << `W) + 2);
endmodule
