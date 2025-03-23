`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2025 12:03:49
// Design Name: 
// Module Name: sprite_renderer_optimized
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


module sprite_renderer_optimized(
    input clk,
    input [12:0] pixel_index,
    input [5:0] character,
    input [6:0] start_x,
    input [5:0] start_y,
    input [15:0] colour,
    output reg [15:0] oled_data,
    output reg active_pixel
    );
    parameter WIDTH = 96;
    parameter HEIGHT = 64;
    parameter CHAR_WIDTH = 8;
    parameter CHAR_HEIGHT = 12;

    // Determine pixel coordinates
    wire [6:0] x = pixel_index % WIDTH;
    wire [5:0] y = pixel_index / WIDTH;

    // Calculate position within character
    wire [3:0] row = (y >= start_y && y < start_y + CHAR_HEIGHT) ? (y - start_y) : 4'd15;
    wire [2:0] col = (x >= start_x && x < start_x + CHAR_WIDTH) ? (x - start_x) : 3'd7;
    
    // Pixel data from ROM
    wire [7:0] pixel_row;
    wire in_bounds = (x >= start_x && x < start_x + CHAR_WIDTH && 
                      y >= start_y && y < start_y + CHAR_HEIGHT);

    // Use optimized sprite library
    sprite_library_optimized char_rom(
        .character(character),
        .row(row),
        .pixels(pixel_row)
    );

    // Output logic
    always @(posedge clk) begin
        active_pixel <= 0;
        oled_data <= 16'b11111_111111_11111;
        
        if (in_bounds && pixel_row[CHAR_WIDTH-1-col]) begin
            oled_data <= colour;
            active_pixel <= 1;
        end
    end
endmodule
