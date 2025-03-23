`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2025 13:06:01
// Design Name: 
// Module Name: graph_display
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


module graph_display (
    input clk,
    //input rst,
    input [12:0] pixel_index,
    input [3:0] zoom_level,    // Simple zoom control via switches
    input [6:0] pan_offset_x,  // Signed panning control
    input [5:0] pan_offset_y,
    input [3:0] coeff_1,
    input [3:0] coeff_2,
    input [3:0] coeff_3,
    input [3:0] coeff_4,
    input [15:0] colour,
    output reg [15:0] oled_data, // OLED pixel data (RGB 565 format)
    output reg oled_valid
);

    // Parameters for screen size
    parameter SCREEN_WIDTH = 96;
    parameter SCREEN_HEIGHT = 64;

    // Coordinates
    wire [6:0]x_pos;
    wire [5:0]y_pos;
    assign x_pos = pixel_index % SCREEN_WIDTH;
    assign y_pos = SCREEN_HEIGHT - (pixel_index / SCREEN_WIDTH);
    
    reg signed [31:0] x_coord = 0;
    reg signed [31:0] y_coord = 0;
    reg signed [31:0] y_plot = 0; //Based on x_coord
    
    reg result = 0;
    reg zoom = 0;
    
    reg [5:0] space = {6{1'b1}};
    wire text_flag = 0;
    wire [15:0] text_colour = 16'b00000_000000_11111;
    
    // Instantiate number sprites at different positions
    
    string_renderer coefficients (
        .clk(clk),
        .pixel_index(pixel_index),
        .word({  {2'b00}, coeff_4, space, {2'b00}, coeff_3, space, {2'b00}, coeff_2, space, {2'b00}, coeff_1, space  }),
        .start_x(20), // X position
        .start_y(14), // Y position
        .colour(16'h0000), // Colour (e.g., red)
        .oled_data(text_colour),
        .active_pixel(text_flag)
    );
        
    // Initialize
    always @(posedge clk) begin
        oled_data = 16'hFFFF;
        oled_valid = 1;
   
        
        x_coord = (x_pos - pan_offset_x) / zoom_level ;
        y_coord = (y_pos - pan_offset_y) / zoom_level ;
        
       // Simple grid rendering (every 10 pixels vertical & horizontal lines)
        if (x_coord % 10 == 0 || y_coord % 10 == 0) begin
            oled_data = 16'h7777; // black grid lines
        end
        if ((x_coord == 0) || (y_coord == 0)) begin
            oled_data = 16'h0000; // black grid lines    
        end

        
        if (
            (
             (
              y_coord != 0 &&  
                
              y_coord < (
              coeff_1 * (x_coord+1) * (x_coord+1) * (x_coord+1) +
              coeff_2 * (x_coord+1) * (x_coord+1) +
              coeff_3 * (x_coord+1) + 
              coeff_4 )
             )
             
             &&
             
             (y_coord > (
              coeff_1 * (x_coord-1) * (x_coord-1) * (x_coord-1) +
              coeff_2 * (x_coord-1) * (x_coord-1) +
              coeff_3 * (x_coord-1) + 
              coeff_4)
             )
            ) 
            
            ||

            (
             y_coord != 0 &&  
             
             (y_coord > (
              coeff_1 * (x_coord+1) * (x_coord+1) * (x_coord+1) +
              coeff_2 * (x_coord+1) * (x_coord+1) +
              coeff_3 * (x_coord+1) + 
              coeff_4 )
             )
             
             &&
             
             (y_coord < (
              coeff_1 * (x_coord-1) * (x_coord-1) * (x_coord-1) +
              coeff_2 * (x_coord-1) * (x_coord-1) +
              coeff_3 * (x_coord-1) + 
              coeff_4 )
             )
            ) 
            ||
             
            y_coord == (
            coeff_1 * (x_coord) * (x_coord) * (x_coord) +
            coeff_2 * (x_coord) * (x_coord) +
            coeff_3 * (x_coord) +  
            coeff_4 )
             //This is the real equation, but the above two conditionas are 
             //added to ensure that steep gradients do not just disappear since 
             //the y coordinates of the pixels that lie on the line are far apart
        ) begin
            oled_data = colour; // Red function line
        end 
        
//        if (y_pos > 0 && y_pos <= 15) begin
//            if (text_flag) begin
//                oled_data = text_colour;
//            end 
//            else begin
//                oled_data = 16'b01111_011111_01111;
//            end
//        end
        
        
    end
    
endmodule
