// 512-Point Iterative FFT Top Module
// Optimized for TOPS SoC - Student ID: EC23I2015
module fft_512_top (
    input clk,
    input reset,
    input start,
    output reg done
);
    // Internal RAM for In-Place computation
    reg signed [15:0] ram_re [0:511];
    reg signed [15:0] ram_im [0:511];

    // FSM State and Counters
    reg [2:0] state;
    reg [3:0] stage;
    reg [8:0] bfly_count, dist, group_ptr;

    // Internal Wires for Sub-modules
    wire [7:0] tw_addr;
    wire [15:0] w_r, w_i, yr0, yi0, yr1, yi1;
    reg signed [15:0] ar, ai, br, bi;

    // Twiddle Addressing Logic
    assign tw_addr = (bfly_count << (stage - 1));

    // Sub-module Instantiations
    twiddle_rom_512 rom_inst (.addr(tw_addr), .wr(w_r), .wi(w_i));
    
    butterfly_512 bf_inst (
        .ar(ar), .ai(ai), .br(br), .bi(bi),
        .wr(w_r), .wi(w_i),
        .yr0(yr0), .yi0(yi0), .yr1(yr1), .yi1(yi1)
    );

    // Finite State Machine (The Conductor)
    always @(posedge clk) begin
        if (reset) begin
            state <= 0; stage <= 1; dist <= 256; done <= 0;
            bfly_count <= 0; group_ptr <= 0;
        end else begin
            case (state)
                0: if (start) state <= 1; // IDLE
                1: begin // FETCH: Load A and B from RAM
                    ar <= ram_re[group_ptr + bfly_count];
                    ai <= ram_im[group_ptr + bfly_count];
                    br <= ram_re[group_ptr + bfly_count + dist];
                    bi <= ram_im[group_ptr + bfly_count + dist];
                    state <= 2;
                end
                2: state <= 3; // WAIT: Butterfly is processing Q15 math
                3: begin // STORE: Write Y0 and Y1 back to RAM
                    ram_re[group_ptr + bfly_count] <= yr0;
                    ram_im[group_ptr + bfly_count] <= yi0;
                    ram_re[group_ptr + bfly_count + dist] <= yr1;
                    ram_im[group_ptr + bfly_count + dist] <= yi1;
                    state <= 4;
                end
                4: begin // NEXT BUTTERFLY
                    if (bfly_count < (dist - 1)) begin
                        bfly_count <= bfly_count + 1;
                        state <= 1;
                    end else if (group_ptr + (2 * dist) < 512) begin
                        group_ptr <= group_ptr + (2 * dist);
                        bfly_count <= 0;
                        state <= 1;
                    end else state <= 5;
                end
                5: begin // NEXT STAGE
                    if (stage < 9) begin
                        stage <= stage + 1; dist <= dist >> 1;
                        group_ptr <= 0; bfly_count <= 0; state <= 1;
                    end else begin
                        done <= 1; state <= 0;
                    end
                end
            endcase
        end
    end
endmodule