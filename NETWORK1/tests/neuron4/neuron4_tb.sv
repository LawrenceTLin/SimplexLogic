`timescale 1ns/1ps
module neuron4_tb;
  localparam IW = 16, OW = 32;

  logic signed [IW-1:0]  in0, in1, in2, in3;
  logic signed [OW-1:0]  out;

  // instantiate your neuron
  neuron4 #(.IW(IW), .OW(OW)) dut (
    .in0(in0), .in1(in1), .in2(in2), .in3(in3),
    .out(out)
  );

  initial begin
    // simple vectors
    in0 = 16'd2; // 2
    in1 = -16'd300; // -3
    in2 = 16'd4; // 4
    in3 = -16'd1573; // 1

    #1; // combinational delay
    $display("out = %0d", out);
    $finish;
  end
endmodule
