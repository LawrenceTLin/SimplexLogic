`timescale 1ns/1ps
module linearLayer_tb;
    //-------------------------------------------------------------------------
    // Parameters
    //-------------------------------------------------------------------------
    localparam int WIDTH = 16;
    localparam int NIN     = 4;
    localparam int NOUT = 3;

    //-------------------------------------------------------------------------
    // TB ↔ DUT ports
    //-------------------------------------------------------------------------
    logic signed [WIDTH-1:0] in_tb  [0:NIN-1];
    wire signed [WIDTH-1:0] out_tb [0:NOUT-1]; // need to make this a wire otherwise it will give x's as outputs (weird ?)

    //-------------------------------------------------------------------------
    // Flat weights matrix (must match DUT’s parameter)
    //-------------------------------------------------------------------------
    localparam logic signed [WIDTH*NIN*NOUT-1:0] WEIGHTS_MATRIX_FLAT = {
        // row 0
         16'sd3000,  16'sd7808, -16'sd2560,  -16'sd77,
        // row 1
         16'sd308,  -16'sd788, -16'sd250,  -16'sd779,
        // row 2
         -16'sd3072,  16'sd7808, -16'sd2560,  -16'sd747
    };

    //-------------------------------------------------------------------------
    // Unpack weights into 2D array for display
    //-------------------------------------------------------------------------
    logic signed [WIDTH-1:0] wt_mat [0:NOUT-1][0:NIN-1];
    genvar gi, gj;
    generate
        for (gi = 0; gi < NOUT; gi = gi + 1) begin : ROW
            for (gj = 0; gj < NIN; gj = gj + 1) begin : COL
                assign wt_mat[gi][gj]
                    = WEIGHTS_MATRIX_FLAT[(NIN*NOUT - (gi*NIN + gj))*WIDTH - 1 -: WIDTH];
            end
        end
    endgenerate

    //-------------------------------------------------------------------------
    // Instantiate the linear layer
    //-------------------------------------------------------------------------
    linearLayer #(
        .WIDTH               (WIDTH),
        .NIN                   (NIN),
        .NOUT                 (NOUT),
        .WEIGHTS_MATRIX_FLAT (WEIGHTS_MATRIX_FLAT)
    ) dut (
        .in  (in_tb),
        .out (out_tb)
    );

    //-------------------------------------------------------------------------
    // Drive + debug prints
    //-------------------------------------------------------------------------
    initial begin
        // 1) drive inputs
        in_tb[0] = -16'd200;
        in_tb[1] =  16'd35;
        in_tb[2] = 16'd77;
        in_tb[3] =  -16'd256;
        #1; // let everything settle

        // 2) show inputs
        $display("\n=== INPUTS ===");
        for (int i = 0; i < NIN; i++)
            $display(" in_tb[%0d] = %0d", i, in_tb[i]);

        // 3) show full unpacked weight matrix
        $display("\n=== WEIGHT MATRIX wt_mat ===");
        for (int i = 0; i < NOUT; i++)
            for (int j = 0; j < NIN; j++)
                $display(" wt_mat[%0d][%0d] = %0d", i, j, wt_mat[i][j]);

        // 4) show exactly what each neuron instance sees as WEIGHTS_FLAT
        $display("\n=== SLICED WEIGHTS_PER NEURON ===");
        $display(" neuron[0] WEIGHTS_FLAT = 0x%0h", dut.gen_neuron[0].neuron_i.WEIGHTS_FLAT);
        $display(" neuron[1] WEIGHTS_FLAT = 0x%0h", dut.gen_neuron[1].neuron_i.WEIGHTS_FLAT);
        $display(" neuron[2] WEIGHTS_FLAT = 0x%0h", dut.gen_neuron[2].neuron_i.WEIGHTS_FLAT);

        // 5) show linearLayer’s output port (out_tb)
        $display("\n=== LINEARLAYER OUTPUTS (out_tb) ===");
        for (int i = 0; i < NOUT; i++)
            $display(" out_tb[%0d] = %0d", i, out_tb[i]);

        // 6) show linearLayer’s internal port net (dut.out)
        $display("\n=== LINEARLAYER INTERNAL PORTS (dut.out) ===");
        $display(" dut.out[0] = %0d", dut.out[0]);
        $display(" dut.out[1] = %0d", dut.out[1]);
        $display(" dut.out[2] = %0d", dut.out[2]);

        // 7) show each neuron’s own output net
        $display("\n=== PER-NEURON OUTPUTS (neuron_i.out) ===");
        $display(" neuron[0].out = %0d", dut.gen_neuron[0].neuron_i.out);
        $display(" neuron[1].out = %0d", dut.gen_neuron[1].neuron_i.out);
        $display(" neuron[2].out = %0d", dut.gen_neuron[2].neuron_i.out);

        $finish;
    end
endmodule
