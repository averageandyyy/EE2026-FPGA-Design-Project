`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.04.2025 02:05:51
// Design Name: 
// Module Name: seven_seg_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module seven_seg_controller(
    output reg [7:0] seg,
    output reg [3:0] an,
    input back_switch,
    input my_1_khz_clk,
    input [3:0] seven_segment_mode,
    input overflow_flag
    );
    
    // Letters for display
    parameter [7:0] A = 8'b10001000;
    parameter [7:0] R = 8'b10101111;
    parameter [7:0] T = 8'b10000111;
    parameter [7:0] H = 8'b10001011;
    parameter [7:0] O = 8'b11000000;
    parameter [7:0] L = 8'b11000111;
    parameter [7:0] D = 8'b10100001;
    parameter [7:0] N = 8'b10101011;
    parameter [7:0] F = 8'b10001110;
    parameter [7:0] U = 8'b11100011;
    parameter [7:0] C = 8'b10100111;
    parameter [7:0] S = 8'b10010010;
    parameter [7:0] E = 8'b10000110;
    parameter [7:0] I = 8'b11111001;
    parameter [7:0] G = 8'b11101111;
    parameter [7:0] P = 6'b11110011;

    // Arrowhead display
    parameter [7:0] HEAD = 8'b10111001;
    parameter [7:0] DASH = 8'b10111111;

    parameter [7:0] BLANK = 8'b11111111;

    // States
    parameter [3:0] STATE_1_2 = 4'b0000;
    parameter [3:0] STATE_ARITHMETIC = 4'b0001;
    parameter [3:0] STATE_FUNCTION = 4'b0010;
    parameter [3:0] STATE_MOUSE = 4'b1111;
    parameter [3:0] STATE_ARITH_OVERFLOW = 4'b0011;
    parameter [3:0] STATE_INTEGRATION = 4'b0011;
    parameter [3:0] STATE_PLOT = 4'b0100;
    
    reg toggle_state = 0;
    reg [19:0] counter = 0; 
    reg [1:0] mux_count = 0;

    reg [12:0] overflow_counter = 0;

    
    always @(posedge my_1_khz_clk) begin
        // reset the anodes
        an <= 4'b1111;

        // always increment counter every clock cycle
        counter <= counter + 1;
        if (counter == 750) begin
            toggle_state <= ~toggle_state;
            counter <= 0;
        end

        // Anoding
        mux_count <= mux_count + 1;
        
        if (seven_segment_mode == STATE_1_2) begin
            case (mux_count)
                2'b00: begin 
                    if (toggle_state) begin
                        if (back_switch) begin
                            seg <= HEAD;
                            an <= 4'b0111;
                        end else begin
                            seg <= H;
                            an <= 4'b0111;
                        end
                    end else begin
                        if (back_switch) begin
                            seg <= BLANK;
                            an <= 4'b0111;
                        end else begin
                            seg <= BLANK;
                            an <= 4'b0111;
                        end
                    end
                end
                
                2'b01: begin
                    if (toggle_state) begin
                        if (back_switch) begin
                            seg <= DASH;
                            an <= 4'b1011;
                        end else begin
                            seg <= O;
                            an <= 4'b1011;
                        end
                    end else begin
                        if (back_switch) begin
                            seg <= BLANK;
                            an <= 4'b1011;
                        end else begin
                            seg <= BLANK;
                            an <= 4'b1011;
                        end
                    end
                end
                
                2'b10: begin
                    if (toggle_state) begin
                        if (back_switch) begin
                            seg <= DASH;
                            an <= 4'b1101;
                        end else begin
                            seg <= L;
                            an <= 4'b1101;
                        end
                    end else begin
                        if (back_switch) begin
                            seg <= BLANK;
                            an <= 4'b1101;
                        end else begin
                            seg <= BLANK;
                            an <= 4'b1101;
                        end
                    end
                end
                
                2'b11: begin  
                    if (toggle_state) begin
                        if (back_switch) begin
                            seg <= DASH;
                            an <= 4'b1110;
                        end else begin
                            seg <= D;
                            an <= 4'b1110;
                        end
                    end else begin
                        if (back_switch) begin
                            seg <= BLANK;
                            an <= 4'b1110;
                        end else begin
                            seg <= BLANK;
                            an <= 4'b1110;
                        end
                    end
                end
            endcase
        end else if (seven_segment_mode == STATE_ARITHMETIC) begin
            if (overflow_flag && overflow_counter == 0) begin
                overflow_counter <= 4000;
            end
            else if (overflow_counter != 0) begin
                // Render SSD for Error
                an <= 4'b0000;
                seg <= E;
                overflow_counter <= overflow_counter - 1;

                case (mux_count)
                    2'b00: begin 
                            seg <= E;
                            an <= 4'b0111;
                    end
                
                    2'b01: begin
                            seg <= R;
                            an <= 4'b1011;
                    end
                
                    2'b10: begin
                            seg <= R;
                            an <= 4'b1101;
                    end
                
                    2'b11: begin  
                            seg <= BLANK;
                            an <= 4'b1110;
                    end
                endcase
            end
            else begin
                case (mux_count)
                    2'b00: begin 
                        if (toggle_state) begin
                            if (back_switch) begin
                                seg <= HEAD;
                                an <= 4'b0111;
                            end else begin
                                seg <= A;
                                an <= 4'b0111;
                            end
                        end else begin
                            if (back_switch) begin
                                seg <= BLANK;
                                an <= 4'b0111;
                            end else begin
                                seg <= A;
                                an <= 4'b0111;
                            end
                        end
                    end
                
                    2'b01: begin
                        if (toggle_state) begin
                            if (back_switch) begin
                                seg <= DASH;
                                an <= 4'b0111;
                            end else begin
                                seg <= R;
                                an <= 4'b0111;
                            end
                        end else begin
                            if (back_switch) begin
                                seg <= DASH;
                                an <= 4'b1011;
                            end else begin
                                seg <= R;
                                an <= 4'b1011;
                            end
                        end
                    end
                
                    2'b10: begin
                        if (toggle_state) begin
                            seg <= T;
                            an <= 4'b1101;
                        end else begin
                            if (back_switch) begin
                                seg <= DASH;
                                an <= 4'b1101;
                            end else begin
                                seg <= T;
                                an <= 4'b1101;
                            end
                        end
                    end
                
                    2'b11: begin  
                        if (toggle_state) begin
                            seg <= H;
                            an <= 4'b1110;
                        end else begin
                            if (~back_switch) begin
                                seg <= DASH;
                                an <= 4'b1110;
                            end else begin
                                seg <= H;
                                an <= 4'b1110;
                            end
                        end
                    end
                endcase
            end
        end else if (seven_segment_mode == STATE_FUNCTION) begin
            case (mux_count)
                2'b00: begin 
                    if (toggle_state) begin
                        seg <= F;
                        an <= 4'b0111;
                    end else begin
                        if (back_switch) begin
                            seg <= HEAD;
                            an <= 4'b0111;
                        end else begin
                            seg <= F;
                            an <= 4'b0111;
                        end
                    end
                end
                
                2'b01: begin
                    if (toggle_state) begin
                        seg <= U;
                        an <= 4'b1011;
                    end else begin
                        if (back_switch) begin
                            seg <= DASH;
                            an <= 4'b1011;
                        end else begin
                            seg <= U;
                            an <= 4'b1011;
                        end
                    end
                end
                
                2'b10: begin
                    if (toggle_state) begin
                        seg <= N;
                        an <= 4'b1101;
                    end else begin
                        if (back_switch) begin
                            seg <= DASH;
                            an <= 4'b1101;
                        end else begin
                            seg <= N;
                            an <= 4'b1101;
                        end
                    end
                end
                
                2'b11: begin  
                    if (toggle_state) begin
                        seg <= C;
                        an <= 4'b1110;
                    end else begin
                        if (back_switch) begin
                            seg <= DASH;
                            an <= 4'b1110;
                        end else begin
                            seg <= C;
                            an <= 4'b1110;
                        end
                    end
                end
            endcase
        end else if (seven_segment_mode == STATE_MOUSE) begin
            case (mux_count)
                2'b00: begin 
                    if (toggle_state) begin
                        seg <= C;
                        an <= 4'b0111;
                    end else begin
                        if (back_switch) begin
                            seg <= HEAD;
                            an <= 4'b0111;
                        end else begin
                            seg <= C;
                            an <= 4'b0111;
                        end
                    end
                end
                
                2'b01: begin
                    if (toggle_state) begin
                        seg <= U;
                        an <= 4'b1011;
                    end else begin
                        if (back_switch) begin
                            seg <= DASH;
                            an <= 4'b1011;
                        end else begin
                            seg <= U;
                            an <= 4'b1011;
                        end
                    end
                end
                
                2'b10: begin
                    if (toggle_state) begin
                        seg <= R;
                        an <= 4'b1101;
                    end else begin
                        if (back_switch) begin
                            seg <= DASH;
                            an <= 4'b1101;
                        end else begin
                            seg <= R;
                            an <= 4'b1101;
                        end
                    end
                end
                
                2'b11: begin  
                    if (toggle_state) begin
                        seg <= S;
                        an <= 4'b1110;
                    end else begin
                        if (back_switch) begin
                            seg <= DASH;
                            an <= 4'b1110;
                        end else begin
                            seg <= S;
                            an <= 4'b1110;
                        end
                    end
                end
            endcase
        end else if (seven_segment_mode == STATE_INTEGRATION) begin
            case (mux_count)
                    2'b00: begin 
                        if (toggle_state) begin
                            seg <= I;
                            an <= 4'b0111;
                        end else begin
                            if (back_switch) begin
                                seg <= I;
                                an <= 4'b0111;
                            end else begin
                                seg <= HEAD;
                                an <= 4'b0111;
                            end
                        end
                    end
                
                    2'b01: begin
                        if (toggle_state) begin
                            seg <= N;
                            an <= 4'b1011;
                        end else begin
                            if (back_switch) begin
                                seg <= N;
                                an <= 4'b1011;
                            end else begin
                                seg <= DASH;
                                an <= 4'b1011;
                            end
                        end
                    end
                
                    2'b10: begin
                        if (toggle_state) begin
                            seg <= T;
                            an <= 4'b1101;
                        end else begin
                            if (back_switch) begin
                                seg <= T;
                                an <= 4'b1101;
                            end else begin
                                seg <= DASH;
                                an <= 4'b1101;
                            end
                        end
                    end
                
                    2'b11: begin  
                        if (toggle_state) begin
                            seg <= G;
                            an <= 4'b1110;
                        end else begin
                            if (back_switch) begin
                                seg <= G;
                                an <= 4'b1110;
                            end else begin
                                seg <= DASH;
                                an <= 4'b1110;
                            end
                        end
                    end
            endcase            
        end else if (seven_segment_mode == STATE_PLOT) begin
            case (mux_count)
                    2'b00: begin 
                        if (toggle_state) begin
                            seg <= P;
                            an <= 4'b0111;
                        end else begin
                            if (back_switch) begin
                                seg <= P;
                                an <= 4'b0111;
                            end else begin
                                seg <= HEAD;
                                an <= 4'b0111;
                            end
                        end
                    end
                
                    2'b01: begin
                        if (toggle_state) begin
                            seg <= L;
                            an <= 4'b1011;
                        end else begin
                            if (back_switch) begin
                                seg <= L;
                                an <= 4'b1011;
                            end else begin
                                seg <= DASH;
                                an <= 4'b1011;
                            end
                        end
                    end
                
                    2'b10: begin
                        if (toggle_state) begin
                            seg <= O;
                            an <= 4'b1101;
                        end else begin
                            if (back_switch) begin
                                seg <= O;
                                an <= 4'b1101;
                            end else begin
                                seg <= DASH;
                                an <= 4'b1101;
                            end
                        end
                    end
                
                    2'b11: begin  
                        if (toggle_state) begin
                            seg <= T;
                            an <= 4'b1110;
                        end else begin
                            if (back_switch) begin
                                seg <= T;
                                an <= 4'b1110;
                            end else begin
                                seg <= DASH;
                                an <= 4'b1110;
                            end
                        end
                    end
            endcase        
        end     
    end    
endmodule
