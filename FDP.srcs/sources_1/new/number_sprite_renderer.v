`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2025 15:18:04
// Design Name: 
// Module Name: number_sprite_renderer
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


module number_sprite_renderer(
    input clk,
    input [3:0] digit,     // Number (0-9)
    input [6:0] x_pos,      // Bottom-right X
    input [6:0] y_pos,      // Bottom-right Y
    output reg [15:0] pixel_data,
    output reg [95:0] screen_buffer [0:63] // OLED buffer
);
    wire [4:0] row_pixels;
    reg [2:0] row = x_pos;
    integer i, j, k, l;

    // Get row-by-row pixel data
    sprite_library row_data(.digit(digit), .row(row), .row_pixels(row_pixels));

    always @(posedge clk) begin
        for (i = 0; i < 7; i = i+1) begin
            // Iterate rows to store bit battern
            for (j = 0; j < 5; j = j + 1) begin   
                // If pixel is ON
                if (row_pixels[j]) begin
                    pixel_data <= colour;
                    screen_buffer[y_pos - i][x_pos - j] <= colour;
                    //screen_buffer[y_pos - (row_index) - j][x_pos - ] <= colour;
                end       
            end
        end 
    end

endmodule
