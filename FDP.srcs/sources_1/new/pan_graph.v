`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.03.2025 16:52:58
// Design Name: 
// Module Name: pan_graph
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


module pan_graph(
    input basys_clk,
    input is_pan,
    input btnU, btnD, btnL, btnR, btnC,
    output reg signed [15:0]pan_offset_x, 
    output reg signed [15:0]pan_offset_y,
    output reg [3:0]zoom_level_x,
    output reg [3:0]zoom_level_y
    );
    
    parameter SCREEN_WIDTH = 96;
    parameter SCREEN_HEIGHT = 64;
    parameter MAX_PAN_X = 100;
    parameter MAX_PAN_y = 100;
    
    initial begin
        //default the origin is at the center
        pan_offset_x = 0;
        pan_offset_y = 0;
        zoom_level_x = 1;
        zoom_level_y = 1;
    end
    
    wire clk_6p25MHz;
    flexible_clock_divider clk_6p25MHz_gen(
        .main_clock(basys_clk),
        .ticks(7),
        .output_clock(clk_6p25MHz)
    );
    
    reg prevBtnU = 0;
    reg prevBtnD = 0;
    reg prevBtnL = 0;
    reg prevBtnR = 0;
    reg prevBtnC = 0;
        
       
    always @ (posedge clk_6p25MHz) begin
        //Zooming
        if (~is_pan) begin
            if (prevBtnU & ~btnU) begin
                zoom_level_y = (zoom_level_y < 8) ? zoom_level_y * 2 : 8;
            end
            if (prevBtnD & ~btnD) begin
                zoom_level_y = (zoom_level_y > 1) ? zoom_level_y / 2 : 1;
            end
            if (prevBtnL & ~btnL) begin
                zoom_level_x = (zoom_level_x < 8) ? zoom_level_x * 2 : 8;
            end
            if (prevBtnR & ~btnR) begin
                zoom_level_x = (zoom_level_x > 1) ? zoom_level_x / 2 : 1;
            end
        end
        
        if (is_pan) begin
            
            if (prevBtnU & ~btnU) begin
                pan_offset_y <= (pan_offset_y >= 90)? 90: pan_offset_y + 2;
            end
            
            if (prevBtnD & ~btnD) begin
                pan_offset_y <= (pan_offset_y <= -90)? -90: pan_offset_y - 2;
            end
            
            if (prevBtnL & ~btnL) begin
               pan_offset_x <= (pan_offset_x <= -90)? -90: pan_offset_x - 2;
            end
            
            if (prevBtnR & ~btnR) begin
                pan_offset_x <= (pan_offset_x >= 90)? 90: pan_offset_x + 2;
            end
        end
        
        prevBtnU <= btnU;
        prevBtnD <= btnD;
        prevBtnL <= btnL;
        prevBtnR <= btnR;
        prevBtnC <= btnC;
    end
endmodule
