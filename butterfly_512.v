module butterfly_512 (
    input signed [15:0] ar, ai, br, bi, // Real/Imag inputs
    input signed [15:0] wr, wi,         // Twiddle Factor (Q15)
    output signed [15:0] yr0, yi0,      // Output Pair 0
    output signed [15:0] yr1, yi1       // Output Pair 1
);
    wire signed [31:0] p_rr, p_ii, p_ri, p_ir;
    reg signed [15:0] b_wr, b_wi;

    // Complex Multiply: B * W (Q15 scaling)
    assign p_rr = (br * wr) >>> 15; 
    assign p_ii = (bi * wi) >>> 15;
    assign p_ri = (br * wi) >>> 15;
    assign p_ir = (bi * wr) >>> 15;

    always @(*) begin
        b_wr = p_rr - p_ii;
        b_wi = p_ri + p_ir;
    end

    // Standard Radix-2 Butterfly Addition/Subtraction
    assign yr0 = ar + b_wr;
    assign yi0 = ai + b_wi;
    assign yr1 = ar - b_wr;
    assign yi1 = ai - b_wi;
endmodule