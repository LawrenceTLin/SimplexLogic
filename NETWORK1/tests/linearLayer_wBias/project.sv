module project #(
  parameter int IW = 32,        // e.g. Q16.16
  parameter int OW = 16         // e.g. Q8.8
) (
  input  logic signed [IW-1:0] in,
  output logic signed [OW-1:0] out
);

    // how many fraction bits in/out
    localparam int FRAC_IN   = IW  >> 1;       // 16
    localparam int FRAC_OUT  = OW  >> 1;       //  8

    // build Q8.8 limits shifted into Q16.16
    localparam logic signed [IW-1:0]
        MAX_Q16 = ((1 << (OW-1)) - 1) << FRAC_OUT,  // +127.99609375×2^16
        MIN_Q16 = (-(1 << (OW-1)))    << FRAC_OUT;  // –128.0000000×2^16
    
    localparam logic signed [OW-1:0]
        MAX_Q8 = ((1 << (OW-1)) - 1), // +127.99609375×2^8
        MIN_Q8 = (-(1 << (OW-1))); // –128.0000000×2^8

    // extract the “middle” OW bits
    logic signed [OW-1:0] slice;
    assign slice = {in[IW-1], in[FRAC_IN + FRAC_OUT - 2 : FRAC_IN-FRAC_OUT]};

    // now do saturate-or-pass-through in one expression
    assign out = (in > MAX_Q16) ? MAX_Q8 :
                    (in < MIN_Q16) ? MIN_Q8 :
                        slice;
                
endmodule
