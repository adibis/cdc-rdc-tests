// Gray-coded payload carried by a four-phase req/ack handshake. The
// source loads the next value only when idle, raises req, and holds
// the payload until the synchronized ack has risen and fallen again.
// The destination captures on the synchronized req's rising edge and
// returns req as the ack. The req-gated capture clears CDC-004 and
// the held payload clears CDC-012. Must stay silent.
module cdc004_gated_gray_bus_clean (
    input  logic ca,
    input  logic cb,
    input  logic rst,
    output logic [1:0] q
);
    logic [1:0] bin_q, gray, src_q, dst_q;
    logic req, ack_m, ack_s;
    logic req_m, req_s, req_d;
    assign gray = bin_q ^ {1'b0, bin_q[1]};
    always_ff @(posedge ca)
        if (rst) begin
            bin_q <= 2'd0;
            src_q <= 2'd0;
            req   <= 1'b0;
            ack_m <= 1'b0;
            ack_s <= 1'b0;
        end else begin
            ack_m <= req_s;
            ack_s <= ack_m;
            if (!req && !ack_s) begin
                src_q <= gray;
                bin_q <= bin_q + 2'd1;
                req   <= 1'b1;
            end else if (req && ack_s) req <= 1'b0;
        end
    always_ff @(posedge cb) begin
        req_m <= req;
        req_s <= req_m;
        req_d <= req_s;
        if (req_s && !req_d) dst_q <= src_q;
    end
    assign q = dst_q;
endmodule
