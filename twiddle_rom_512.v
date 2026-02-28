module twiddle_rom_512 (
    input [7:0] addr, 
    output reg signed [15:0] wr, 
    output reg signed [15:0] wi
);
    always @(*) begin
        case(addr)
            8'h00: begin wr = 16'h7FFF; wi = 16'h0000; end // W^0 (1.0, 0.0)
            8'h40: begin wr = 16'h5A82; wi = 16'hA57E; end // W^64 (0.707, -0.707)
            8'h80: begin wr = 16'h0000; wi = 16'h8000; end // W^128 (0.0, -1.0)
            8'hC0: begin wr = 16'hA57E; wi = 16'hA57E; end // W^192 (-0.707, -0.707)
            default: begin wr = 16'h7FFF; wi = 16'h0000; end
        endcase
    end
endmodule