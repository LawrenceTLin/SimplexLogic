module neuron #(
    parameter int WIDTH  = 16,              // bit‐width of each input
    parameter int N      = 4,               // number of inputs
    parameter [WIDTH*N-1:0] WEIGHTS_FLAT = {N{WIDTH'(0)}}
)(
    input  logic signed [WIDTH-1:0] in [N-1:0],  // vector of inputs
    output logic signed [WIDTH-1:0] out            // projected dot‐product
);

    // each product will be twice the width of an input
    logic signed [2*WIDTH-1:0] products [N-1:0];
    logic signed [2*WIDTH-1:0] sum;

    genvar i;
    generate
    for (i = 0; i < N; i = i + 1) begin : MUL
        // slice out the i-th WIDTH-bit chunk from WEIGHTS_FLAT
        const_mul #(
            .WIDTH    (WIDTH),
            .OUT_WIDTH(2*WIDTH),
            .WEIGHT   ( $signed(WEIGHTS_FLAT[(N-i)*WIDTH -1 -: WIDTH]) )
            ) mul_i (
            .in  (in[i]),
            .out (products[i])
        );
    end
    endgenerate

    // accumulate all N products
    always_comb begin
        sum = '0;
        for (int j = 0; j < N; j++)
            sum += products[j];
    end

    // saturating projector back down to WIDTH bits
    project #(
        .IW(2*WIDTH),
        .OW(WIDTH)
        ) proj (
        .in (sum),
        .out(out)
    );

endmodule
