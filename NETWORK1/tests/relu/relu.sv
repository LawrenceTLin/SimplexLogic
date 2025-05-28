module relu #(
    WIDTH = 16, // bit‐width of input and output
    N = 4 // number of components in input and output vector
) (
    input logic signed [WIDTH-1:0] in [0:N-1], // input vector
    output logic signed [WIDTH-1:0] out [0:N-1] // output vector
);

    always_comb begin
        for (int i=0; i<N; i++) begin
            // Apply ReLU activation function: max(0, x)
            if (in[i] < 0)
                out[i] = '0; // if input is negative, output is 0
            else
                out[i] = in[i]; // if input is non-negative, output is the same as input
        end
    end

endmodule