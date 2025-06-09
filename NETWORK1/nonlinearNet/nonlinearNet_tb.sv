`timescale 1ns/1ps
module linearNet_tb;
    //-------------------------------------------------------------------------
    // Parameters
    //-------------------------------------------------------------------------
    localparam int WIDTH = 16;
    localparam int NIN     = 2;
    localparam int NOUT1 = 16;
    localparam int NOUT2 = 4;
    localparam int NOUT = 2;

    //-------------------------------------------------------------------------
    // TB ↔ DUT ports
    //-------------------------------------------------------------------------
    logic signed [WIDTH-1:0] in_tb  [0:NIN-1];
    wire signed [WIDTH-1:0] out_tb [0:NOUT-1]; // need to make this a wire otherwise it will give x's as outputs

    //-------------------------------------------------------------------------
    // Flat weights matrix (must match DUT’s parameter)
    //-------------------------------------------------------------------------

    localparam logic signed [WIDTH*NIN*NOUT1-1:0] WEIGHTS_MATRIX_FLAT1 = {
-16'd23 , -16'd153 , 
16'd113 , -16'd154 , 
-16'd65 , 16'd138 , 
16'd219 , 16'd30 , 
16'd66 , 16'd125 , 
-16'd116 , -16'd84 , 
-16'd39 , -16'd196 , 
16'd16 , 16'd56 , 
-16'd148 , 16'd190 , 
16'd28 , 16'd146 , 
16'd152 , -16'd77 , 
16'd102 , 16'd44 , 
-16'd97 , -16'd101 , 
-16'd79 , -16'd134 , 
-16'd28 , -16'd62 , 
16'd134 , 16'd59
    };

    localparam logic signed [WIDTH*NOUT1-1:0] BIAS_FLAT1 = {
16'd123 , 
-16'd37 , 
-16'd173 , 
16'd207 , 
16'd119 , 
-16'd40 , 
16'd28 , 
16'd23 , 
16'd68 , 
16'd128 , 
16'd6 , 
16'd157 , 
16'd145 , 
16'd36 , 
16'd139 , 
16'd234 
    };

    localparam logic signed [WIDTH*NOUT1*NOUT2-1:0] WEIGHTS_MATRIX_FLAT2 = {
16'd98 , 16'd41 , -16'd49 , 16'd52 , -16'd107 , 16'd16 , 16'd102 , -16'd109 , 16'd70 , -16'd28 , 16'd53 , -16'd89 , 16'd97 , 16'd139 , 16'd96 , -16'd36 , 
16'd169 , -16'd15 , -16'd67 , -16'd33 , -16'd22 , 16'd29 , 16'd72 , -16'd61 , 16'd4 , -16'd5 , 16'd5 , -16'd11 , 16'd74 , 16'd127 , 16'd40 , -16'd23 , 
-16'd95 , -16'd74 , 16'd3 , 16'd173 , 16'd133 , 16'd1 , -16'd12 , 16'd3 , 16'd75 , 16'd138 , -16'd13 , 16'd174 , -16'd25 , -16'd11 , -16'd45 , 16'd125 , 
16'd48 , 16'd31 , -16'd17 , -16'd6 , -16'd9 , 16'd124 , 16'd143 , 16'd0 , 16'd34 , -16'd60 , -16'd58 , -16'd88 , 16'd61 , 16'd51 , 16'd97 , -16'd36 

    };

    localparam logic signed [WIDTH*NOUT2-1:0] BIAS_FLAT2 = {
16'd55 , 
16'd23 , 
16'd53 , 
16'd78
    };

    localparam logic signed [WIDTH*NOUT2*NOUT-1:0] WEIGHTS_MATRIX_FLAT3 = {
-16'd192 , -16'd160 , 16'd125 , -16'd62 , 
16'd142 , -16'd61 , -16'd187 , 16'd158
    };

    localparam logic signed [WIDTH*NOUT-1:0] BIAS_FLAT3 = {
16'd60 , 
-16'd94 
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

    logic signed [WIDTH-1:0] b1 [0:NOUT1-1];
    genvar b1i;
    generate
        for (b1i = 0; b1i < NOUT1; b1i = b1i + 1) begin : BIAS1
            assign b1[b1i] = BIAS_FLAT1[(NOUT1 - 1 - b1i)*WIDTH +: WIDTH];
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

    logic signed [WIDTH-1:0] b2 [0:NOUT2-1];
    genvar b2i;
    generate
        for (b2i = 0; b2i < NOUT2; b2i = b2i + 1) begin : BIAS2
            assign b2[b2i] = BIAS_FLAT2[(NOUT2 - 1 - b2i)*WIDTH +: WIDTH];
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

    logic signed [WIDTH-1:0] b3 [0:NOUT-1];
    genvar b3i;
    generate
        for (b3i = 0; b3i < NOUT; b3i = b3i + 1) begin : BIAS3
            assign b3[b3i] = BIAS_FLAT3[(NOUT - 1 - b3i)*WIDTH +: WIDTH];
        end
    endgenerate

    //-------------------------------------------------------------------------
    // Instantiate the linear layer
    //-------------------------------------------------------------------------
    nonlinearNet #(
        .WIDTH               (WIDTH),
        .NIN                   (NIN),
        .NOUT1                 (NOUT1),
        .NOUT2                 (NOUT2),
        .NOUT                 (NOUT),
        .WEIGHTS_MATRIX_FLAT1 (WEIGHTS_MATRIX_FLAT1),
        .BIAS_FLAT1           (BIAS_FLAT1),
        .WEIGHTS_MATRIX_FLAT2 (WEIGHTS_MATRIX_FLAT2),
        .BIAS_FLAT2           (BIAS_FLAT2),
        .WEIGHTS_MATRIX_FLAT3 (WEIGHTS_MATRIX_FLAT3),
        .BIAS_FLAT3           (BIAS_FLAT3)
    ) dut (
        .in  (in_tb),
        .out (out_tb)
    );

    //-------------------------------------------------------------------------
    // Drive + debug prints
    //-------------------------------------------------------------------------
    initial begin
        // 1) drive inputs
        in_tb[0] = -16'd512;
        in_tb[1] =  -16'd256;
        #1; // let everything settle

        // 2) show inputs
        $display("\n=== INPUTS ===");
        for (int i = 0; i < NIN; i++)
            $display(" in_tb[%0d] = %0d", i, in_tb[i]);

        // show weights and biases
        $display("\n=== WEIGHT MATRIX wt_mat1 ===");
        for (int i = 0; i < NOUT1; i++)
            for (int j = 0; j < NIN; j++)
                $display(" wt_mat1[%0d][%0d] = %0d", i, j, wt_mat1[i][j]);

        $display("\n=== BIAS VECTOR bias1 ===");
        for (int i = 0; i < NOUT1; i++)
            $display(" bias1[%0d] = %0d", i, b1[i]);

        $display("\n=== WEIGHT MATRIX wt_mat2 ===");
        for (int i = 0; i < NOUT2; i++)
            for (int j = 0; j < NOUT1; j++)
                $display(" wt_mat2[%0d][%0d] = %0d", i, j, wt_mat2[i][j]);

        $display("\n=== BIAS VECTOR bias2 ===");
        for (int i = 0; i < NOUT2; i++)
            $display(" bias2[%0d] = %0d", i, b2[i]);

        $display("\n=== WEIGHT MATRIX wt_mat3 ===");
        for (int i = 0; i < NOUT; i++)
            for (int j = 0; j < NOUT2; j++)
                $display(" wt_mat3[%0d][%0d] = %0d", i, j, wt_mat3[i][j]);
        
        $display("\n=== BIAS VECTOR bias3 ===");
        for (int i = 0; i < NOUT; i++)
            $display(" bias3[%0d] = %0d", i, b3[i]);

        // 5) show linearLayer’s output port (out_tb)
        $display("\n=== OUTPUTS (out_tb) ===");
        for (int i = 0; i < NOUT; i++)
            $display(" out_tb[%0d] = %0d", i, out_tb[i]);

        $finish;
    end
endmodule
