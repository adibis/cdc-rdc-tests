// Two-bit source sliced lane by lane into separate sync chains: each
// lane resolves apart. Must report CDC-020 on the source register.
module cdc020_sliced_bus_apart (
    input  logic ca,
    input  logic cb,
    input  logic [1:0] d,
    output logic [1:0] q
);
    logic [1:0] src_q;
    logic m0, s0, m1, s1;
    always_ff @(posedge ca) src_q <= d;
    always_ff @(posedge cb) m0 <= src_q[0];
    always_ff @(posedge cb) s0 <= m0;
    always_ff @(posedge cb) m1 <= src_q[1];
    always_ff @(posedge cb) s1 <= m1;
    assign q = {s1, s0};
endmodule
