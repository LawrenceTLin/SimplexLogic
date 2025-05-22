`timescale 1ns/1ps
module const_mul_tb;
  localparam WIDTH = 16;
  logic signed [WIDTH-1:0]  in;
  logic signed [2*WIDTH-1:0]  out;

  localparam logic signed [WIDTH-1:0] WEIGHT = -16'd8;

  // instantiate your neuron
  const_mul #(.WIDTH(WIDTH), .OUT_WIDTH(WIDTH*2), .WEIGHT(WEIGHT)) dut (
    .in(in), .out(out)
  );

  initial begin
    // simple vectors
    in = -16'd26;

    #1; // combinational delay
    $display("out = %0d", out);
    $finish;
  end

endmodule
