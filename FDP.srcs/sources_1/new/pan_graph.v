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
    input pan_zoom_toggle,
    output reg signed [15:0]pan_offset_x, 
    output reg signed [15:0]pan_offset_y,
    output reg signed  [3:0]zoom_level_x,
    output reg signed [3:0]zoom_level_y
);
    
    parameter SCREEN_WIDTH = 96;
    parameter SCREEN_HEIGHT = 64;
    parameter MAX_PAN = 200;
    parameter DEBOUNCE_COUNTS = 947000;
    
    reg is_pan;
    reg prevBtnU = 0;
    reg prevBtnD = 0;
    reg prevBtnL = 0;
    reg prevBtnR = 0;
    reg prevBtnC = 0;
    reg prevleft = 0;

    reg [31:0] debounce_counter_C = 0;
    reg [31:0] debounce_counter_U = 0;
    reg [31:0] debounce_counter_D = 0;
    reg [31:0] debounce_counter_L = 0;
    reg [31:0] debounce_counter_R = 0;
    
      
    always @ (posedge clk) begin
        if (is_graphing_mode) begin

        if (debounce_counter_U > 0) debounce_counter_U <= debounce_counter_U - 1; //Count down
        if (debounce_counter_D > 0) debounce_counter_D <= debounce_counter_D - 1;
        if (debounce_counter_L > 0) debounce_counter_L <= debounce_counter_L - 1;
        if (debounce_counter_R > 0) debounce_counter_R <= debounce_counter_R - 1; 
        if (debounce_counter_C > 0) debounce_counter_C <= debounce_counter_C - 1;

            // Toggle pan/zoom mode on center button press
            if ((btnC & ~prevBtnC) && (debounce_counter_C == 0)) begin
                is_pan <= ~is_pan;
                debounce_counter_C <= DEBOUNCE_COUNTS;
            end

            //Zooming
            if (~is_pan) begin                        
                //try this logic: zoom wrt y is regular scroll
                //if want to zoom wrt x, hold down right click
                if (prevBtnU & ~btnU) begin
                    zoom_level_y = (zoom_level_y < 3) ? zoom_level_y + 1 : 3;
                    debounce_counter_U <= DEBOUNCE_COUNTS;
                end
                if (prevBtnD & ~btnD) begin
                    zoom_level_y = (zoom_level_y > 0) ? zoom_level_y - 1 : 0;
                    debounce_counter_D <= DEBOUNCE_COUNTS;
                end
                if (prevBtnL & ~btnL) begin
                    zoom_level_x = (zoom_level_x < 3) ? zoom_level_x + 1 : 3;
                    debounce_counter_L <= DEBOUNCE_COUNTS;
                end
                if (prevBtnR & ~btnR) begin
                    zoom_level_x = (zoom_level_x > 0) ? zoom_level_x - 1: 0;
                    debounce_counter_R <= DEBOUNCE_COUNTS;
                end
            end
            
            else if (is_pan) begin
                // Otherwise, if the left mouse button is not held, use button inputs.
                if (prevBtnU && ~btnU && is_graphing_mode) begin
                    debounce_counter_U <= DEBOUNCE_COUNTS;
                    if (pan_offset_y >= MAX_PAN)
                        pan_offset_y <= MAX_PAN;
                    else
                        pan_offset_y <= pan_offset_y + 2;
                end
                if (prevBtnD && ~btnD) begin
                    debounce_counter_D <= DEBOUNCE_COUNTS;
                    if (pan_offset_y <= -MAX_PAN)
                        pan_offset_y <= -MAX_PAN;
                    else
                        pan_offset_y <= pan_offset_y - 2;
                end
                if (prevBtnL && ~btnL) begin
                    debounce_counter_L <= DEBOUNCE_COUNTS;
                    if (pan_offset_x <= -MAX_PAN)
                        pan_offset_x <= -MAX_PAN;
                    else
                        pan_offset_x <= pan_offset_x - 2;
                end
                if (prevBtnR && ~btnR) begin
                    debounce_counter_R <= DEBOUNCE_COUNTS;
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
       if (pan_zoom_toggle) begin
            prevBtnU <= btnU;
            prevBtnD <= btnD;
            prevBtnL <= btnL;
            prevBtnR <= btnR;
            prevBtnC <= btnC;
        end
    end
endmodule
