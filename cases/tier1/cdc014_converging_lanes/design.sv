// Two source-domain lanes converge through an OR gate into one
// synchronizer whose stages sandwich an AND gate (second leg a
// live destination-domain enable): CDC-004 fires on the 2-bit
// bus, CDC-014 fires once on the inter-stage gate, both at head.
module cdc014_converging_lanes (
    input  logic ca,
    input  logic cb,
    input  logic d1,
    input  logic d2,
    input  logic en,
    output logic q
);
    logic [1:0] s;
    logic m;
    logic h;
    logic g;
    logic t;
    always_ff @(posedge ca) s <= {d2, d1};
    assign m = s[0] | s[1];
    always_ff @(posedge cb) h <= m;
    assign g = h & en;
    always_ff @(posedge cb) t <= g;
    assign q = t;
endmodule
