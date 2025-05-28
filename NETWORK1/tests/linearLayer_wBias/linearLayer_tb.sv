`timescale 1ns/1ps

// Testbench for a simple 2×2 linearLayer in Q8.8 fixed‑point (16‑bit)
module linearLayer_tb;
  //----------------------------------------------------------------------
  // Parameters for Q8.8 (8 integer + 8 fractional → 16‑bit total)
  //----------------------------------------------------------------------
  localparam int WIDTH = 16;      // total bit‑width
  localparam int NIN   = 2;
  localparam int NOUT  = 2;

  //----------------------------------------------------------------------
  // Test vectors (real ↔ Q8.8)
  //----------------------------------------------------------------------
  // inputs: [1.5, -0.25] → [1.5*256=384, -0.25*256=-64]
  logic signed [WIDTH-1:0] in_tb [0:NIN-1];

  // weights:
  //   row0: [ 1.0, -0.5] → [256, -128]
  //   row1: [ 0.25,  2.0] → [ 64,  512]
  localparam logic signed [WIDTH*NIN*NOUT-1:0] WEIGHTS_FLAT = {
      16'sd256, -16'sd128,
        16'sd64,  16'sd512
  };

  // biases: [0.125, -1.0] → [0.125*256=32, -1.0*256=-256]
  localparam logic signed [WIDTH*NOUT-1:0] BIAS_FLAT = {16'd32, -16'd256};

  wire signed [WIDTH-1:0] out_tb [0:NOUT-1];

  //---------------------------------------------------------------------
  // Instantiate a manual 2×2 neuron array (mimics linearLayer)
  //---------------------------------------------------------------------
  genvar i;
  generate
    for (i = 0; i < NOUT; i++) begin : NEURONS
      neuron #(
        .WIDTH     (WIDTH),
        .N         (NIN),
        .WEIGHTS_FLAT({WEIGHTS_FLAT[(NOUT-i)*WIDTH*NIN-1 -: WIDTH*NIN]}),
        .BIAS      (BIAS_FLAT[(NOUT-i)*WIDTH-1 -: WIDTH])
      ) u_neuron (
        .in  (in_tb),
        .out (out_tb[i])
      );
    end
  endgenerate

  //---------------------------------------------------------------------
  // Compute golden results in Q8.8
  //---------------------------------------------------------------------
  integer j;
  initial begin
    in_tb[0] = 16'sd384;  // 1.5 in Q8.8
    in_tb[1] = -16'sd64;  // -0.25 in Q8.8

    #1; // allow outputs to settle
    $display("\nQ8.8 LinearLayer Test");
    for (j = 0; j < NOUT; j++) begin
      $display(" Neuron %0d: out_tb = %0d", j, out_tb[j]);
    end
    $finish;
  end
endmodule