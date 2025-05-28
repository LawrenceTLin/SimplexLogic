`timescale 1ns/1ps
module linearNet_tb;
    //-------------------------------------------------------------------------
    // Parameters
    //-------------------------------------------------------------------------
    localparam int WIDTH = 16;
    localparam int NIN     = 4;
    localparam int NOUT1 = 3;
    localparam int NOUT2 = 3;
    localparam int NOUT = 2;

    //-------------------------------------------------------------------------
    // TB ↔ DUT ports
    //-------------------------------------------------------------------------
    logic signed [WIDTH-1:0] in_tb  [0:NIN-1];
    wire signed [WIDTH-1:0] out_tb [0:NOUT-1]; // need to make this a wire otherwise it will give x's as outputs (weird ?)

    //-------------------------------------------------------------------------
    // Flat weights matrix (must match DUT’s parameter)
    //-------------------------------------------------------------------------
    localparam logic signed [WIDTH*NIN*NOUT1-1:0] WEIGHTS_MATRIX_FLAT1 = {
        // row 0
         16'sd30,  16'sd780, -16'sd25,  -16'sd77,
        // row 1
         16'sd308,  -16'sd78, -16'sd250,  -16'sd779,
        // row 2
         -16'sd302,  16'sd788, -16'sd250,  -16'sd77
    };

    localparam logic signed [WIDTH*NOUT1*NOUT2-1:0] WEIGHTS_MATRIX_FLAT2 = {
        // row 0
         16'sd30,  16'sd780, -16'sd25,
        // row 1
         16'sd308,  -16'sd78, -16'sd250,
        // row 2
         -16'sd302,  16'sd788, -16'sd250
    };

    localparam logic signed [WIDTH*NOUT2*NOUT-1:0] WEIGHTS_MATRIX_FLAT3 = {
        // row 0
         16'sd30,  16'sd780, -16'sd25,
        // row 1
         16'sd308,  -16'sd78, -16'sd250
    };

    //-------------------------------------------------------------------------
    // Unpack weights into 2D array for display
    //-------------------------------------------------------------------------
    logic signed [WIDTH-1:0] wt_mat1 [0:NOUT1-1][0:NIN-1];
    genvar g1i, g1j;
    generate
        for (g1i = 0; g1i < NOUT1; g1i = g1i + 1) begin : ROW1
            for (g1j = 0; g1j < NIN; g1j = g1j + 1) begin : COL1
                assign wt_mat1[g1i][g1j]
                    = WEIGHTS_MATRIX_FLAT1[(NIN*NOUT1 - (g1i*NIN + g1j))*WIDTH - 1 -: WIDTH];
            end
        end
    endgenerate

    logic signed [WIDTH-1:0] wt_mat2 [0:NOUT2-1][0:NOUT1-1];
    genvar g2i, g2j;
    generate
        for (g2i = 0; g2i < NOUT2; g2i = g2i + 1) begin : ROW2
            for (g2j = 0; g2j < NOUT1; g2j = g2j + 1) begin : COL2
                assign wt_mat2[g2i][g2j]
                    = WEIGHTS_MATRIX_FLAT2[(NOUT1*NOUT2 - (g2i*NOUT1 + g2j))*WIDTH - 1 -: WIDTH];
            end
        end
    endgenerate

    logic signed [WIDTH-1:0] wt_mat3 [0:NOUT-1][0:NOUT2-1];
    genvar g3i, g3j;
    generate
        for (g3i = 0; g3i < NOUT; g3i = g3i + 1) begin : ROW3
            for (g3j = 0; g3j < NOUT2; g3j = g3j + 1) begin : COL3
                assign wt_mat3[g3i][g3j]
                    = WEIGHTS_MATRIX_FLAT3[(NOUT2*NOUT - (g3i*NOUT2 + g3j))*WIDTH - 1 -: WIDTH];
            end
        end
    endgenerate

    //-------------------------------------------------------------------------
    // Instantiate the linear layer
    //-------------------------------------------------------------------------
    linearNet #(
        .WIDTH               (WIDTH),
        .NIN                   (NIN),
        .NOUT1                 (NOUT1),
        .NOUT2                 (NOUT2),
        .NOUT                 (NOUT),
        .WEIGHTS_MATRIX_FLAT1 (WEIGHTS_MATRIX_FLAT1),
        .WEIGHTS_MATRIX_FLAT2 (WEIGHTS_MATRIX_FLAT2),
        .WEIGHTS_MATRIX_FLAT3 (WEIGHTS_MATRIX_FLAT3)
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
        $display("\n=== WEIGHT MATRIX wt_mat1 ===");
        for (int i = 0; i < NOUT1; i++)
            for (int j = 0; j < NIN; j++)
                $display(" wt_mat1[%0d][%0d] = %0d", i, j, wt_mat1[i][j]);
        // 3) show full unpacked weight matrix
        $display("\n=== WEIGHT MATRIX wt_mat2 ===");
        for (int i = 0; i < NOUT2; i++)
            for (int j = 0; j < NOUT1; j++)
                $display(" wt_mat2[%0d][%0d] = %0d", i, j, wt_mat2[i][j]);
        // 3) show full unpacked weight matrix
        $display("\n=== WEIGHT MATRIX wt_mat3 ===");
        for (int i = 0; i < NOUT; i++)
            for (int j = 0; j < NOUT2; j++)
                $display(" wt_mat3[%0d][%0d] = %0d", i, j, wt_mat3[i][j]);

        // 5) show linearLayer’s output port (out_tb)
        $display("\n=== OUTPUTS (out_tb) ===");
        for (int i = 0; i < NOUT; i++)
            $display(" out_tb[%0d] = %0d", i, out_tb[i]);

        $finish;
    end
endmodule
