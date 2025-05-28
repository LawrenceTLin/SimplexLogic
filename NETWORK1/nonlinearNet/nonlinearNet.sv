module nonlinearNet #(
    parameter int WIDTH = 16, // bit width of input
    parameter int NIN = 2, // size of input vector from 1st layer
    parameter int NOUT1 = 16, // size of output vector from 1st layer
    parameter int NOUT2 = 4, // size of input vector from 2nd layer
    parameter int NOUT = 2, // size of output vector from 3rd layer
    parameter [WIDTH*NIN*NOUT1-1:0] WEIGHTS_MATRIX_FLAT1 = {(NIN*NOUT1){WIDTH'(0)}},
    parameter [WIDTH*NOUT1-1:0] BIAS_FLAT1 = {(NOUT1){WIDTH'(0)}},
    parameter [WIDTH*NOUT1*NOUT2-1:0] WEIGHTS_MATRIX_FLAT2 = {(NOUT1*NOUT2){WIDTH'(0)}},
    parameter [WIDTH*NOUT2-1:0] BIAS_FLAT2 = {(NOUT2){WIDTH'(0)}},
    parameter [WIDTH*NOUT2*NOUT-1:0] WEIGHTS_MATRIX_FLAT3 = {(NOUT2*NOUT){WIDTH'(0)}},
    parameter [WIDTH*NOUT-1:0] BIAS_FLAT3 = {(NOUT){WIDTH'(0)}}
) (
    input logic signed [WIDTH-1:0] in [0:NIN-1], // vector of inputs
    output wire signed [WIDTH-1:0] out [0:NOUT-1] // output - must be a wire since driven also by test bench output
);

    wire signed [WIDTH-1:0] out1 [0:NOUT1-1]; // output from 1st layer - must be a wire since eventually drives output
    linearLayer #(
        .WIDTH               (WIDTH),
        .NIN                   (NIN),
        .NOUT                 (NOUT1),
        .WEIGHTS_MATRIX_FLAT (WEIGHTS_MATRIX_FLAT1),
        .BIAS_FLAT           (BIAS_FLAT1)
    ) layer1 (
        .in  (in),
        .out (out1)
    );

    wire signed [WIDTH-1:0] out1_post [0:NOUT1-1]; // output from 1st layer post activation
    relu #(
        .WIDTH (WIDTH),
        .N     (NOUT1)
    ) relu1 (
        .in  (out1),
        .out (out1_post)
    );

    wire signed [WIDTH-1:0] out2 [0:NOUT2-1]; // output from 2nd layer - must be a wire since eventually drives output
    linearLayer #(
        .WIDTH               (WIDTH),
        .NIN                   (NOUT1),
        .NOUT                 (NOUT2),
        .WEIGHTS_MATRIX_FLAT (WEIGHTS_MATRIX_FLAT2),
        .BIAS_FLAT           (BIAS_FLAT2)
    ) layer2 (
        .in  (out1_post),
        .out (out2)
    );

    wire signed [WIDTH-1:0] out2_post [0:NOUT2-1]; // output from 2nd layer post activation
    relu #(
        .WIDTH (WIDTH),
        .N     (NOUT2)
    ) relu2 (
        .in  (out2),
        .out (out2_post)
    );

    // final layer
    linearLayer #(
        .WIDTH               (WIDTH),
        .NIN                   (NOUT2),
        .NOUT                 (NOUT),
        .WEIGHTS_MATRIX_FLAT (WEIGHTS_MATRIX_FLAT3),
        .BIAS_FLAT           (BIAS_FLAT3)
    ) layer3 (
        .in  (out2_post),
        .out (out)
    );
    
endmodule