`timescale 1ns/1ps
module neuron_full_dbg_tb;
  //-------------------------------------------------------------------------
  // Parameters
  //-------------------------------------------------------------------------
  localparam int WIDTH = 16;
  localparam int N     = 4;

  //-------------------------------------------------------------------------
  // Testbench ↔ DUT ports
  //-------------------------------------------------------------------------
  // TB drives this array…
  logic signed [WIDTH-1:0] in_tb  [0:N-1];
  // … DUT drives this single result
  logic signed [WIDTH-1:0] out_tb;

  //-------------------------------------------------------------------------
  // Flat weights (must match DUT’s parameter)
  //-------------------------------------------------------------------------
  localparam logic signed [WIDTH*N-1:0] WEIGHTS_FLAT = {
    16'd3072,
    16'd7808,
    -16'd2560,
    -16'd77
  };

  //-------------------------------------------------------------------------
  // Unpack those into 4×16-bit for easy display
  //-------------------------------------------------------------------------
  logic signed [WIDTH-1:0] wt [0:N-1];
  genvar gi;
  generate
    for (gi = 0; gi < N; gi = gi + 1) begin : UNPACK_W
      // indexed part-select: chunk gi
      assign wt[gi] = WEIGHTS_FLAT[(N-gi)*WIDTH-1 -: WIDTH];
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Instantiate your neuron
  //-------------------------------------------------------------------------
  neuron #(
    .WIDTH       (WIDTH),
    .N           (N),
    .WEIGHTS_FLAT(WEIGHTS_FLAT)
  ) dut (
    .in  (in_tb),
    .out (out_tb)
  );

  //-------------------------------------------------------------------------
  // We'll snapshot these from inside the DUT
  //-------------------------------------------------------------------------
  logic signed [2*WIDTH-1:0] prod_dbg [0:N-1];
  logic signed [2*WIDTH-1:0] sum_dbg;

  //-------------------------------------------------------------------------
  // Drive + debug
  //-------------------------------------------------------------------------
  initial begin
    $display("\n=== DRIVING INPUT VECTOR ===");
    in_tb[0] =  -16'd384;
    in_tb[1] = 16'd358;
    in_tb[2] = -16'd77;
    in_tb[3] = 16'd2586;

    #1; // let everything settle

    // 1) show that TB’s in[] matches DUT’s in[]
    $display("\n=== INPUTS (TB vs DUT) ===");
    for (int i = 0; i < N; i++) begin
      $display(" in_tb[%0d] = %0d,   dut.in[%0d] = %0d",
               i, in_tb[i], i, dut.in[i]);
    end

    // 2) show the weights
    $display("\n=== WEIGHTS ===");
    for (int i = 0; i < N; i++)
      $display(" wt[%0d] = %0d", i, wt[i]);

    // 3) capture and print each product
    $display("\n=== PRODUCTS ===");
    for (int i = 0; i < N; i++) begin
      prod_dbg[i] = dut.products[i];
      $display(" product[%0d] = %0d (0x%0h)",
               i, prod_dbg[i], prod_dbg[i]);
    end

    // 4) running accumulation
    $display("\n=== PARTIAL SUMS ===");
    sum_dbg = prod_dbg[0];
    $display(" sum after product[0]  = %0d", sum_dbg);
    for (int i = 1; i < N; i = i + 1) begin
      sum_dbg += prod_dbg[i];
      $display(" sum after product[%0d] = %0d", i, sum_dbg);
    end

    // 5) final DUT internals + output
    $display("\n=== FINAL ===");
    $display(" dut.sum  (32-bit full) = %0d", dut.sum);
    $display(" out_tb   (projected)   = %0d\n", out_tb);

    $finish;
  end
endmodule
