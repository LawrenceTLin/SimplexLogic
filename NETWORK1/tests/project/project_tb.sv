`timescale 1ns/1ps
module project_tb;
  localparam IW = 32, OW = 16;

  logic signed [IW-1:0]  in;
  logic signed [OW-1:0]  out;

  // instantiate your neuron
  project #(.IW(IW), .OW(OW)) dut (
    .in(in),
    .out(out)
  );

  initial begin
    // simple vectors
    in = -32'd11797135;
    #1; // combinational delay
    $display("out = %0d", out);
    $finish;
  end
endmodule
