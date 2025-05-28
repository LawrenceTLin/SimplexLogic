`timescale 1ns/1ps

module relu_tb;
    //-------------------------------------------------------------------------
    // Parameters
    //-------------------------------------------------------------------------
    localparam int WIDTH = 16;
    localparam int N     = 4;

    //-------------------------------------------------------------------------
    // Testbench signals
    //-------------------------------------------------------------------------
    logic signed [WIDTH-1:0] in_vec  [0:N-1];
    wire signed [WIDTH-1:0] out_vec [0:N-1];

    //-------------------------------------------------------------------------
    // Instantiate ReLU module
    //-------------------------------------------------------------------------
    relu #(
        .WIDTH(WIDTH),
        .N(N)
    ) uut (
        .in (in_vec),
        .out(out_vec)
    );

    //-------------------------------------------------------------------------
    // Stimulus and checks
    //-------------------------------------------------------------------------
    initial begin
        $display("\nTime  Input Vector             Output Vector");
        $display("----  ------------------------  ------------------------");

        // Test 1: all non-negative
        in_vec[0] = 16'sd0;
        in_vec[1] = 16'sd1;
        in_vec[2] = 16'sd123;
        in_vec[3] = 16'sd32767;
        #1; print_vectors();

        // Test 2: all negative
        in_vec[0] = -16'sd1;
        in_vec[1] = -16'sd123;
        in_vec[2] = -16'sd32768;
        in_vec[3] = -16'sd5;
        #1; print_vectors();

        // Test 3: mixed
        in_vec[0] = -16'sd10;
        in_vec[1] = 16'sd0;
        in_vec[2] = 16'sd20;
        in_vec[3] = -16'sd30;
        #1; print_vectors();
    end

    //-------------------------------------------------------------------------
    // Task to display vectors neatly
    //-------------------------------------------------------------------------
    task automatic print_vectors();
        integer i;
        begin
            $write("%0t    ", $time);
            for (i = 0; i < N; i++) begin
                $write("%0d%s", in_vec[i], (i < N-1 ? ", " : "    ")); 
            end
            for (i = 0; i < N; i++) begin
                $write("%0d%s", out_vec[i], (i < N-1 ? ", " : "\n"));
            end
        end
    endtask
endmodule
