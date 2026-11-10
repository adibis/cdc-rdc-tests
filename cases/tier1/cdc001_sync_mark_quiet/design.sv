// Vouched destination: the capture flop's output carries
// (* cdc_sync *), asserting a vetted synchronizer downstream
// of what the tool can see. CDC-001 must stay silent.
module cdc001_sync_mark_quiet (
    input  logic ca,
    input  logic cb,
    input  logic d,
    output logic q
);
    logic a;
    (* cdc_sync *) logic qs;
    always_ff @(posedge ca) a <= d;
    always_ff @(posedge cb) qs <= a;
    assign q = qs;
endmodule
