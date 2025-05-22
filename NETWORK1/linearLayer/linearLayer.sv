module linearLayer #(
    parameter int WIDTH = 16,              // bit‐width of input and weights
    parameter int N = 4,               // size of input vector
    parameter [WIDTH*N*N-1:0] WEIGHTS_MATRIX_FLAT = {(N*N){WIDTH'(0)}} // flattened weights for entire layer
) (
    input  logic signed [WIDTH-1:0] in [0:N-1],  // vector of inputs
    output logic signed [WIDTH-1:0] out [0:N-1]         // projected dot‐product for each neuron
);
    // generate the neurons
    genvar r;
    generate
        for (r = 0; r < N; r++) begin : gen_neuron
            localparam int  ROW_MSB = (N*N - N*r)*WIDTH - 1;
            localparam logic signed [N*WIDTH-1:0] ROW_WEIGHTS =
                    WEIGHTS_MATRIX_FLAT[ROW_MSB -: N*WIDTH];

            neuron #(
                .WIDTH       (WIDTH),
                .N           (N),
                .WEIGHTS_FLAT(ROW_WEIGHTS)
            ) neuron_i (
                .in  (in),
                .out (out[r])
            );
        end
    endgenerate

endmodule