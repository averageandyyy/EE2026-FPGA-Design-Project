`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2025 17:06:40
// Design Name: 
// Module Name: render_segments
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


module render_segments(
    input basys_clk,
    input is_integrate,
    output reg [3:0]an,
    output reg [7:0]seg
    );
    
    parameter [7:0]I = 8'b1_11111001;
    parameter [7:0]N = 8'b0_0101011;
    parameter [7:0]T = 8'b1_0111001;
    parameter [7:0]G = 8'b1_0100000;
    
    reg [1:0] state;
    
    wire clk_500Hz;
    flexible_clock_divider clk_500Hz_gen(.main_clock(basys_clk), .ticks(99999), .output_clock(clk_500Hz));
    
    initial begin
        state = 2'b0;
        an = 4'b1111;
        seg = 8'b1_1111111;
    end
    
    always @ (posedge clk_500Hz) begin
        if (is_integrate) begin
            if (state == 2'b00) begin
                an <= 4'b0111;
                seg <= I;
            end
            else if (state == 2'b01) begin
                an <= 4'b1011;
                seg <= N;
            end
            else if (state == 2'b10) begin
                an <= 4'b1101;
                seg <= T;
            end
            else if (state == 2'b11) begin
                an <= 4'b1110;
                seg <= G;
            end
            
            state <= state + 1;
        end
    end
endmodule
