`timescale 1ns/1ps
module neuron4_tb;
  localparam IW = 16, OW = 32;

  logic signed [IW-1:0]  in0, in1, in2, in3;
  logic signed [IW-1:0]  out;

  // instantiate your neuron
  localparam W0 = 307, W1 = -896, W2 = 26, W3 = -8;
  neuron4 #(.IW(IW), .OW(OW), .W0(W0), .W1(W1), .W2(W2), .W3(W3)) dut (
    .in0(in0), .in1(in1), .in2(in2), .in3(in3),
    .out(out)
  );

  initial begin
    // simple vectors
    in0 = 16'd384;
    in1 = -16'd51;
    in2 = -16'd77;
    in3 = -16'd26;

    #1; // combinational delay
    $display("out = %0d", out);
    $finish;
  end
endmodule
