// Typed async port feeding a 2FF chain: silent at the default bar,
// but short once the site minimum rises to 3. Must report CDC-002
// on the chain head with --sync-depth 3.
module cdc002_port_chain_short (
    input  logic ca,
    input  logic cb,
    input  logic p,
    output logic q
);
    logic s1;
    logic s2;
    always_ff @(posedge cb) s1 <= p;
    always_ff @(posedge cb) s2 <= s1;
    assign q = s2;
endmodule
