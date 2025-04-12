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
    input left,
    input right,
    input mouse_x,
    input mouse_y,
    input zpos,
    input new_event,
    input btnU, btnD, btnL, btnR, btnC,
    output reg signed [15:0]pan_offset_x, 
    output reg signed [15:0]pan_offset_y,
    output reg [3:0]zoom_level_x,
    output reg [3:0]zoom_level_y ,
    output reg [15:0]led
);
    
    parameter SCREEN_WIDTH = 96;
    parameter SCREEN_HEIGHT = 64;
    parameter MAX_PAN = 200;
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
    
    //scroll wheel debouncing
    reg signed [3:0] zpos_prev = 0;
    reg [19:0] cooldown_counter = 0;
    reg cooldown_active = 0;
    //end of scroll wheel debounce
       
    always @ (posedge basys_clk) begin
        //Zooming
        if (~is_pan) begin
            if (cooldown_active) begin
                if (cooldown_counter > 0)
                   cooldown_counter <= cooldown_counter - 1;
                else
                    cooldown_active <= 0;
            end 
//            if (new_event) begin
            else if (new_event && $signed(zpos) != 0) begin
                // Only trigger if scroll input is non-zero
                if ($signed(zpos) > zpos_prev) begin
                    if (right)
                    //scroll down = zoom out
                        zoom_level_x = (zoom_level_x > 1) ? zoom_level_x / 2 : 1;
                    else zoom_level_y = (zoom_level_y > 1) ? zoom_level_y / 2 : 1;
                                
                end
                else if ($signed(zpos) < zpos_prev) begin
                    //scroll up = zoom in
                    if (right) zoom_level_x = (zoom_level_x < 8) ? zoom_level_x * 2 : 8;
                    else zoom_level_y = (zoom_level_y < 8) ? zoom_level_y * 2 : 8;
                end
                zpos_prev <= $signed(zpos);
                       
                // Start cooldown
                cooldown_active <= 1;
                cooldown_counter <= 20'd1000000; // ~10ms cooldown
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
                        if (prevBtnU && ~btnU || ((curr_x >= 19) && (curr_x <= 76) && (curr_y >= 0) && (curr_y<= 12) && (~left && prevleft))) begin
                            if (pan_offset_y >= MAX_PAN)
                                pan_offset_y <= MAX_PAN;
                            else
                                pan_offset_y <= pan_offset_y + 2;
                        end
                        if (prevBtnD && ~btnD || ((curr_x >= 19) && (curr_x <= 76) && (curr_y >= 51) && (curr_y <= 63) && (~left && prevleft) )) begin
                            if (pan_offset_y <= -MAX_PAN)
                                pan_offset_y <= -MAX_PAN;
                            else
                                pan_offset_y <= pan_offset_y - 2;
                        end
                        if (prevBtnL && ~btnL || ((curr_x >= 0) && (curr_x <= 18) && (curr_y >= 0) && (curr_y <= 63) && (~left && prevleft) )) begin
                            if (pan_offset_x <= -MAX_PAN)
                                pan_offset_x <= -MAX_PAN;
                            else
                                pan_offset_x <= pan_offset_x - 2;
                        end
                        if (prevBtnR && ~btnR || ((curr_x >= 77) && (curr_x <= 95) && (curr_y >= 0) && (curr_y <= 63) && (~left && prevleft) )) begin
                            if (pan_offset_x >= MAX_PAN)
                                pan_offset_x <= MAX_PAN;
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
