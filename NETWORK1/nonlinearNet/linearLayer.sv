module linearLayer #(
    parameter int WIDTH = 16,              // bit‐width of input and weights
    parameter int NIN = 4,               // size of input vector
    parameter int NOUT = 4,              // size of output vector
    parameter [WIDTH*NIN*NOUT-1:0] WEIGHTS_MATRIX_FLAT = {(NIN*NOUT){WIDTH'(0)}}, // flattened weights for entire layer
    parameter [WIDTH*NOUT-1:0] BIAS_FLAT = {(NOUT){WIDTH'(0)}} // flattened bias for entire layer
) (
    input  logic signed [WIDTH-1:0] in [0:NIN-1],  // vector of inputs
    output logic signed [WIDTH-1:0] out [0:NOUT-1]         // projected dot‐product for each neuron
);
    // generate the neurons
    genvar r;
    generate
        for (r = 0; r < NOUT; r++) begin : gen_neuron
            localparam int  ROW_MSB = NIN*(NOUT - r)*WIDTH - 1;
            localparam logic signed [NIN*WIDTH-1:0] ROW_WEIGHTS = WEIGHTS_MATRIX_FLAT[ROW_MSB -: NIN*WIDTH];
            localparam logic signed [WIDTH-1:0] BIAS = BIAS_FLAT[WIDTH*(NOUT - r) - 1 -: WIDTH];

            neuron #(
                .WIDTH       (WIDTH),
                .N           (NIN),
                .WEIGHTS_FLAT(ROW_WEIGHTS),
                .BIAS        (BIAS)
            ) neuron_i (
                .in  (in),
                .out (out[r])
            );
        end
    endgenerate

endmodule