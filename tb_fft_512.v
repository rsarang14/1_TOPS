module tb_fft_512();
    reg clk, reset, start;
    wire done;
    integer i;
    real r_val, i_val;

    // Instantiate Top Module
    fft_512_top uut (.clk(clk), .reset(reset), .start(start), .done(done));

    initial begin
        $display("--- Starting 512-Point DFT Check: EC23I2015 ---");
        clk = 0; reset = 1; start = 0;
        
        // Load initial data into UUT RAM (Simulating a real signal)
        for (i = 0; i < 512; i = i + 1) begin
            uut.ram_re[i] = (i < 256) ? 16'd500 : -16'd500; // Square wave
            uut.ram_im[i] = 16'd0;
        end

        #20 reset = 0; start = 1; #10;
        
        // Wait for FSM to finish all stages
        wait(done); 
        
        $display("\n======================================================");
        $display("   FINAL 512-POINT FFT RESULTS (Q15 Format)          ");
        $display("======================================================");
        $display(" Bin | Real (Int) | Imag (Int) | Decimal Equivalent ");
        $display("-----|------------|------------|----------------------");

        for (i = 0; i < 512; i = i + 1) begin
            // Conversion for the transcript window
            r_val = uut.ram_re[i] / 32768.0;
            i_val = uut.ram_im[i] / 32768.0;
            
            $display("%3d  | %10d | %10d | %1.3f + %1.3fj", 
                     i, uut.ram_re[i], uut.ram_im[i], r_val, i_val);
        end
        $display("======================================================");
        $display("Computation Complete at Time %t", $time);
        $finish;
    end
    always #5 clk = ~clk;
endmodule