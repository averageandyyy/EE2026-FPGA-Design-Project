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
    input clk, //6p25MHz clock
    input is_graphing_mode,
    input btnU, btnD, btnL, btnR, btnC,
    output reg signed [15:0]pan_offset_x, 
    output reg signed [15:0]pan_offset_y,
    output reg signed  [3:0]zoom_level_x,
    output reg signed [3:0]zoom_level_y
);
    
    parameter SCREEN_WIDTH = 96;
    parameter SCREEN_HEIGHT = 64;
    parameter MAX_PAN = 200;
    
    reg is_pan;
    
    reg prevBtnU = 0;
    reg prevBtnD = 0;
    reg prevBtnL = 0;
    reg prevBtnR = 0;
    reg prevBtnC = 0;
    reg prevleft = 0;
    
      
    always @ (posedge clk) begin
        if (is_graphing_mode) begin

            // Toggle pan/zoom mode on center button press
            if (btnC && !prevBtnC) begin
                is_pan <= ~is_pan;
            end

            //Zooming
            if (~is_pan) begin                        
                //try this logic: zoom wrt y is regular scroll
                //if want to zoom wrt x, hold down right click
                if (prevBtnU & ~btnU) begin
                    zoom_level_y = (zoom_level_y < 3) ? zoom_level_y + 1 : 3;
                end
                if (prevBtnD & ~btnD) begin
                    zoom_level_y = (zoom_level_y > 0) ? zoom_level_y - 1 : 0;
                end
                if (prevBtnL & ~btnL) begin
                    zoom_level_x = (zoom_level_x < 3) ? zoom_level_x + 1 : 3;
                end
                if (prevBtnR & ~btnR) begin
                    zoom_level_x = (zoom_level_x > 0) ? zoom_level_x - 1: 0;
                end
            end
            
            else if (is_pan) begin
                // Otherwise, if the left mouse button is not held, use button inputs.
                if (prevBtnU && ~btnU && is_graphing_mode) begin
                    if (pan_offset_y >= MAX_PAN)
                        pan_offset_y <= MAX_PAN;
                    else
                        pan_offset_y <= pan_offset_y + 2;
                end
                if (prevBtnD && ~btnD) begin
                    if (pan_offset_y <= -MAX_PAN)
                        pan_offset_y <= -MAX_PAN;
                    else
                        pan_offset_y <= pan_offset_y - 2;
                end
                if (prevBtnL && ~btnL) begin
                    if (pan_offset_x <= -MAX_PAN)
                        pan_offset_x <= -MAX_PAN;
                    else
                        pan_offset_x <= pan_offset_x - 2;
                end
                if (prevBtnR && ~btnR) begin
                    if (pan_offset_x >= MAX_PAN)
                        pan_offset_x <= MAX_PAN;
                    else
                        pan_offset_x <= pan_offset_x + 2;
                end
            end
        end 
        else if (~is_graphing_mode) begin
            //Reset the origin is at the center whenever graph is not on
            pan_offset_x = 0;
            pan_offset_y = 0;
            zoom_level_x = 0;
            zoom_level_y = 0;

            //Default panning mode
            is_pan = 0;
        end 

       // In all cases, update the previous mouse position.
        prevBtnU <= btnU;
        prevBtnD <= btnD;
        prevBtnL <= btnL;
        prevBtnR <= btnR;
        prevBtnC <= btnC;
    end
endmodule
