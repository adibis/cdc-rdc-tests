// Muxed async reset: a mux selects the async reset leg with no
// local synchronizer. Must report RDC-006 on the consumer.
module rdc006_muxed_reset (
    input  logic clk,
    input  logic ra,
    input  logic rb,
    input  logic sel,
    input  logic d,
    output logic q
);
    logic rst_m;
    assign rst_m = sel ? rb : ra;
    always_ff @(posedge clk or posedge rst_m)
        if (rst_m) q <= 1'b0; else q <= d;
endmodule
