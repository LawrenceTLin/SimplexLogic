`timescale 1ns/1ps
module linearNet_tb;
    //-------------------------------------------------------------------------
    // Parameters
    //-------------------------------------------------------------------------
    localparam int WIDTH = 32;
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
-32'd5916 , -32'd39244 , 
32'd28933 , -32'd39403 , 
-32'd16724 , 32'd35287 , 
32'd56055 , 32'd7715 , 
32'd16962 , 32'd31910 , 
-32'd29692 , -32'd21627 , 
-32'd9888 , -32'd50242 , 
32'd4197 , 32'd14327 , 
-32'd37967 , 32'd48717 , 
32'd7262 , 32'd37283 , 
32'd38900 , -32'd19827 , 
32'd26189 , 32'd11158 , 
-32'd24809 , -32'd25883 , 
-32'd20229 , -32'd34228 , 
-32'd7049 , -32'd15944 , 
32'd34371 , 32'd15034
    };

    localparam logic signed [WIDTH*NOUT1-1:0] BIAS_FLAT1 = {
32'd31597 , 
-32'd9496 , 
-32'd44189 , 
32'd53006 , 
32'd30443 , 
-32'd10184 , 
32'd7231 , 
32'd5789 , 
32'd17467 , 
32'd32885 , 
32'd1492 , 
32'd40308 , 
32'd37208 , 
32'd9159 , 
32'd35577 , 
32'd59895
    };

    localparam logic signed [WIDTH*NOUT1*NOUT2-1:0] WEIGHTS_MATRIX_FLAT2 = {
32'd24995 , 32'd10579 , -32'd12461 , 32'd13322 , -32'd27347 , 32'd4056 , 32'd26213 , -32'd27961 , 32'd17955 , -32'd7192 , 32'd13467 , -32'd22666 , 32'd24775 , 32'd35702 , 32'd24492 , -32'd9277 , 
32'd43299 , -32'd3764 , -32'd17241 , -32'd8389 , -32'd5702 , 32'd7299 , 32'd18304 , -32'd15674 , 32'd1107 , -32'd1356 , 32'd1274 , -32'd2826 , 32'd19008 , 32'd32562 , 32'd10354 , -32'd5869 , 
-32'd24215 , -32'd18908 , 32'd652 , 32'd44374 , 32'd34034 , 32'd157 , -32'd3043 , 32'd810 , 32'd19224 , 32'd35364 , -32'd3215 , 32'd44507 , -32'd6444 , -32'd2845 , -32'd11467 , 32'd32010 , 
32'd12293 , 32'd7902 , -32'd4319 , -32'd1445 , -32'd2424 , 32'd31732 , 32'd36514 , 32'd111 , 32'd8697 , -32'd15431 , -32'd14873 , -32'd22627 , 32'd15548 , 32'd13135 , 32'd24902 , -32'd9308 

    };

    localparam logic signed [WIDTH*NOUT2-1:0] BIAS_FLAT2 = {
32'd14046 , 
32'd5835 , 
32'd13508 , 
32'd20014
    };

    localparam logic signed [WIDTH*NOUT2*NOUT-1:0] WEIGHTS_MATRIX_FLAT3 = {
-32'd49149 , -32'd41000 , 32'd32012 , -32'd15996 , 
32'd36395 , -32'd15512 , -32'd47810 , 32'd40555 
    };

    localparam logic signed [WIDTH*NOUT-1:0] BIAS_FLAT3 = {
32'd15276 , 
-32'd23962
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
        in_tb[0] = -32'd131072;
        in_tb[1] =  -32'd65536;
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
