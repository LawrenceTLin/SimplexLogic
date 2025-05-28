module const_mul #(
    parameter int WIDTH = 16, // bit width of input
    parameter int OUT_WIDTH = 32, //bit width of output
    parameter int WEIGHT = 1 // constant weight
) (
    input logic signed [WIDTH-1:0] in, // signed input vector
    output logic signed [OUT_WIDTH-1:0] out // signed output vector
);

logic signed [OUT_WIDTH-1:0] partials [WIDTH-1:0]; // create an vector of size WIDTH of partial products, each component is of size OUT_WIDTH.

localparam int WEIGHT_mag = (WEIGHT >= 0) ? WEIGHT : -WEIGHT; // absolute value of weight
logic [WIDTH-1:0] in_mag; // absolute value of input
assign in_mag = (in >= 0) ? in : -in; // absolute value of input

genvar i;
generate
    for (i=0; i<WIDTH; i=i+1) begin: gen_partial
        if ((WEIGHT_mag >> i) & 1) // check if the i-th bit of WEIGHT is 1
            assign partials[i] = in_mag << i; // shift left by i bits
        else
            assign partials[i] = '0; // if weight is 0, set partial product to 0
    end
endgenerate

// Combinational adder - sum all partial products
integer j;
always_comb begin
    out = '0; // initialize output to 0
    for (j=0; j<WIDTH; j=j+1) begin
        if ((WEIGHT < 0 & in > 0) | (WEIGHT > 0 & in < 0))
            out -= partials[j]; // accumulate partial products
        else
            out += partials[j]; // accumulate partial products
    end

end

endmodule