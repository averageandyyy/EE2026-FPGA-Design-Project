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
    input my_1_khz_clk
    );
    
    parameter [7:0] H = 8'b10001011;
    parameter [7:0] O = 8'b11000000;
    parameter [7:0] L = 8'b11000111;
    parameter [7:0] D = 8'b10100001;
    parameter [7:0] N = 8'b10101011;
    parameter [7:0] F = 8'b10001110;
    parameter [7:0] BLANK = 8'b11111111;
    
    reg toggle_state = 0;
    reg [19:0] counter = 0; 
    reg [1:0] mux_count = 0;
    
    always @(posedge my_1_khz_clk) begin
        counter <= counter + 1;
        if (counter == 750) begin
            toggle_state <= ~toggle_state;
            counter <= 0;
        end
        mux_count <= mux_count + 1;
        
        case (mux_count)
            2'b00: begin 
                if (toggle_state) begin
                    seg <= H;
                    an <= 4'b0111;
                end else begin
                    if (~back_switch) begin
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
                    seg <= O;
                    an <= 4'b1011;
                end else begin
                    if (~back_switch) begin
                        seg <= O;
                        an <= 4'b1011;
                    end else begin
                        seg <= O;
                        an <= 4'b1011;
                    end
                end
            end
            
            2'b10: begin
                if (toggle_state) begin
                    seg <= L;
                    an <= 4'b1101;
                end else begin
                    if (~back_switch) begin
                        seg <= N;
                        an <= 4'b1101;
                    end else begin
                        seg <= F;
                        an <= 4'b1101;
                    end
                end
            end
            
            2'b11: begin  
                if (toggle_state) begin
                    seg <= D;
                    an <= 4'b1110;
                end else begin
                    if (~back_switch) begin
                        seg <= BLANK;
                        an <= 4'b1110;
                    end else begin
                        seg <= F;
                        an <= 4'b1110;
                    end
                end
            end
        endcase
    end    
    
endmodule
