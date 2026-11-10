// Split reset nets: async and sync resets come from separate
// ports, so RDC-011 stays silent. Clean case.
module rdc011_split_nets (
    input  logic clk,
    input  logic rst_a,
    input  logic rst_s,
    input  logic d,
    output logic q
);
    logic a_q;
    always_ff @(posedge clk or posedge rst_a)
        if (rst_a) a_q <= 1'b0; else a_q <= d;
    always_ff @(posedge clk)
        if (rst_s) q <= 1'b0; else q <= a_q;
endmodule
