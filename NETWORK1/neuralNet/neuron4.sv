// ---------- neuron4.sv (fix out‑width) ----------
module neuron4 #(
    parameter int IW = 16,
    parameter int OW = 32,
    parameter int W0 = 256, W1 = 256, W2 = 256, W3 = 256
)(
    input  logic signed [IW-1:0] in0, in1, in2, in3,
    output logic signed [IW-1:0] out      // stays 16‑bit after projection
);
    logic signed [OW-1:0] p0, p1, p2, p3, sum;
    // four fixed multipliers
    const_mul #(.WIDTH(IW), .OUT_WIDTH(OW), .WEIGHT(W0)) mul0(.in(in0), .out(p0));
    const_mul #(.WIDTH(IW), .OUT_WIDTH(OW), .WEIGHT(W1)) mul1(.in(in1), .out(p1));
    const_mul #(.WIDTH(IW), .OUT_WIDTH(OW), .WEIGHT(W2)) mul2(.in(in2), .out(p2));
    const_mul #(.WIDTH(IW), .OUT_WIDTH(OW), .WEIGHT(W3)) mul3(.in(in3), .out(p3));

    assign sum = p0 + p1 + p2 + p3;

    // 32‑→16‑bit saturating projector
    project #(.IW(OW), .OW(IW)) proj (.in(sum), .out(out));
endmodule
