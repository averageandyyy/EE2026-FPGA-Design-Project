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
    input basys_clk, //6p25MHz clock
    input clk_100MHz,
    input is_pan,
    input is_pan_mouse,
    input left,
    input right,
    input [11:0] mouse_x,
    input [11:0] mouse_y,
    input use_mouse,
    input zpos,
    input new_event,
    input rst,
    input btnU, btnD, btnL, btnR, btnC,
    output reg signed [15:0]pan_offset_x, 
    output reg signed [15:0]pan_offset_y,
    output reg [3:0]zoom_level_x,
    output reg [3:0]zoom_level_y,
    output reg [15:0]led
);
    
    parameter SCREEN_WIDTH = 96;
    parameter SCREEN_HEIGHT = 64;
    parameter MAX_PAN_X = 100;
    parameter MAX_PAN_y = 100;
    wire [6:0] curr_x;
    wire [6:0] curr_y;
    mouse_coordinate_extractor unit_b (basys_clk,
    mouse_x,    // 12-bit mouse x position
    mouse_y,    // 12-bit mouse y position
    curr_x,
    curr_y
    );
    
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
    reg prevleft = 0;
    
    wire [1:0] scroll_dir;
    scroll_led_accum scroll_test (
    .clk        (clk_6p25MHz),
    .rst         (0),
    .new_event   (new_event),
    .zpos        (zpos),
    .wow (scroll_dir));
    //scroll up is 10, scroll down is 01, no input is 00 on the next clk cycle
       
    always @ (posedge basys_clk) begin
        //Zooming
        if (~is_pan) begin
                // Only trigger if scroll input is non-zero
            if (scroll_dir == 01) begin
                if (right)
                    //scroll down = zoom out
                    zoom_level_x = (zoom_level_x > 1) ? zoom_level_x / 2 : 1;
                else zoom_level_y = (zoom_level_y > 1) ? zoom_level_y / 2 : 1;
                            
            end
            else if (scroll_dir == 10) begin
                //scroll up = zoom in
                if (right) zoom_level_x = (zoom_level_x < 8) ? zoom_level_x * 2 : 8;
                else zoom_level_y = (zoom_level_y < 8) ? zoom_level_y * 2 : 8;
            end
                        
        //try this logic: zoom wrt y is regular scroll
        //if want to zoom wrt x, hold down right click
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
        
        else if (is_pan) begin
               
//            if (left) begin
//              // When left mouse button is held, update panning smoothly:
//                        pan_offset_x <= {9'b0, mouse_x};  // extend mouse_x (7 bits) to 16 bits
//                        pan_offset_y <= {9'b0, mouse_y};
//             end 
                        // Otherwise, if the left mouse button is not held, use button inputs.
                        if (prevBtnU && ~btnU || ((is_pan_mouse) && (use_mouse) && (curr_x >= 19) && (curr_x <= 76) && (curr_y >= 0) && (curr_y<= 12) && (~left && prevleft))) begin
                            if (pan_offset_y >= 90)
                                pan_offset_y <= 90;
                            else
                                pan_offset_y <= pan_offset_y + 2;
                        end
                        if (prevBtnD && ~btnD || ((is_pan_mouse) && (use_mouse) && (curr_x >= 19) && (curr_x <= 76) && (curr_y >= 51) && (curr_y <= 63) && (~left && prevleft) )) begin
                            if (pan_offset_y <= -90)
                                pan_offset_y <= -90;
                            else
                                pan_offset_y <= pan_offset_y - 2;
                        end
                        if (prevBtnL && ~btnL || ((is_pan_mouse) && (use_mouse) && (curr_x >= 0) && (curr_x <= 18) && (curr_y >= 0) && (curr_y <= 63) && (~left && prevleft) )) begin
                            if (pan_offset_x <= -90)
                                pan_offset_x <= -90;
                            else
                                pan_offset_x <= pan_offset_x - 2;
                        end
                        if (prevBtnR && ~btnR || ((is_pan_mouse) && (use_mouse) && (curr_x >= 77) && (curr_x <= 95) && (curr_y >= 0) && (curr_y <= 63) && (~left && prevleft) )) begin
                            if (pan_offset_x >= 90)
                                pan_offset_x <= 90;
                            else
                                pan_offset_x <= pan_offset_x + 2;
                        end
                    end
                    led[13:7] = curr_x;
                    led[6:0] = curr_y;

       // In all cases, update the previous mouse position.
        prevBtnU <= btnU;
        prevBtnD <= btnD;
        prevBtnL <= btnL;
        prevBtnR <= btnR;
        prevBtnC <= btnC;
        prevleft <= left;
    end
endmodule
