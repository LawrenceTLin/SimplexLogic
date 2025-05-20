// neuron4.sv
// This module implements a simple neuron with 4 inputs.
module neuron4 #(
    parameter int IW = 16, // bit width of input
    parameter int OW = 32 // bit width of output
)
(
    input logic signed [IW-1:0] in0, in1, in2, in3, // input vectors
    output logic signed [OW-1:0] out // output vector
);

  // Hard-code your four weights here:
  localparam int W0 = 30;   // e.g.  3.0 in Q8.8
  localparam int W1 = -51;   // e.g.  5.0
  localparam int W2 = -11;  // e.g. 10.0
  localparam int W3 = 17;   // e.g.  7.0

  // wires to hold each product
  logic signed [OW-1:0] p0, p1, p2, p3;

  // instantiate four constant multipliers
  const_mul #(.WIDTH(IW), .OUT_WIDTH(OW), .WEIGHT(W0)) mul0 (.in(in0), .out(p0));
  const_mul #(.WIDTH(IW), .OUT_WIDTH(OW), .WEIGHT(W1)) mul1 (.in(in1), .out(p1));
  const_mul #(.WIDTH(IW), .OUT_WIDTH(OW), .WEIGHT(W2)) mul2 (.in(in2), .out(p2));
  const_mul #(.WIDTH(IW), .OUT_WIDTH(OW), .WEIGHT(W3)) mul3 (.in(in3), .out(p3));

  // Combinational adder - sum all partial products
  assign out = p0 + p1 + p2 + p3;

endmodule