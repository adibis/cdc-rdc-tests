// Typed async port into an opposite-edge chain: posedge head,
// negedge tail. Must report CDC-016 on the head; the unregistered
// port source also trips CDC-006 by design.
module cdc016_port_driven (
    input  logic ca,
    input  logic cb,
    input  logic p,
    output logic q
);
    logic s1, s2;
    always_ff @(posedge cb) s1 <= p;
    always_ff @(negedge cb) s2 <= s1;
    assign q = s2;
endmodule
