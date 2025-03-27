`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2025 11:16:43
// Design Name: 
// Module Name: string_renderer_optimized
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


module string_renderer_optimized(
    input clk,
    input [47:0] word,
    input [6:0] start_x,
    input [5:0] start_y,
    input [12:0] pixel_index,
    input [15:0] colour,
    output reg [15:0] oled_data,
    output reg active_pixel
    );

    // Instead of instantiating 8 renderers, we instantiate 1 and update the char on the fly
    parameter CHAR_WIDTH = 8;

    // Current pixel coordinates
    wire [6:0] x = pixel_index % 96;
    wire [5:0] y = pixel_index / 96;

    // Extract characters upfront (only once)
    wire [5:0] chars[0:7];
    assign chars[0] = word[47:42];
    assign chars[1] = word[41:36];
    assign chars[2] = word[35:30];
    assign chars[3] = word[29:24];
    assign chars[4] = word[23:18];
    assign chars[5] = word[17:12];
    assign chars[6] = word[11:6];
    assign chars[7] = word[5:0];

    // Calculate x range once
    wire in_x_range = (x >= start_x) && (x < start_x + (CHAR_WIDTH * 8));

    // Determine which character position we're in without loop
    reg [2:0] char_pos;
    reg [5:0] current_char;

    // Calculate character position and coordinates
    always @ (*) begin
        // Default to first character
        char_pos = 0;
        current_char = chars[0];

        // Finding the character that the current pixel belongs to
        if (in_x_range) begin
            // Position determination with cascaded logic instead of loop
            if (x < start_x + CHAR_WIDTH) begin
                char_pos = 0;
                current_char = chars[0];
            end
            else if (x < start_x + (CHAR_WIDTH * 2)) begin
                char_pos = 1;
                current_char = chars[1];
            end
            else if (x < start_x + (CHAR_WIDTH * 3)) begin
                char_pos = 2;
                current_char = chars[2];
            end
            else if (x < start_x + (CHAR_WIDTH * 4)) begin
                char_pos = 3;
                current_char = chars[3];
            end
            else if (x < start_x + (CHAR_WIDTH * 5)) begin
                char_pos = 4;
                current_char = chars[4];
            end
            else if (x < start_x + (CHAR_WIDTH * 6)) begin
                char_pos = 5;
                current_char = chars[5];
            end
            else if (x < start_x + (CHAR_WIDTH * 7)) begin
                char_pos = 6;
                current_char = chars[6];
            end
            else begin
                char_pos = 7;
                current_char = chars[7];
            end
        end
    end

    // Use bit shift instead of multiplication (CHAR_WIDTH=8 so this is char_pos << 3)
    wire [6:0] char_x = start_x + {char_pos, 3'b000};

    // Single sprite renderer
    wire [15:0] char_data;
    wire char_active;

    sprite_renderer_optimized char_renderer(
        .clk(clk),
        .pixel_index(pixel_index),
        .character(current_char),
        .start_x(char_x),
        .start_y(start_y),
        .colour(colour),
        .oled_data(char_data),
        .active_pixel(char_active)
    );

    always @ (posedge clk) begin    
        if (char_active) begin
            oled_data <= char_data;
            active_pixel <= 1;
        end
        else begin
            oled_data <= 16'b0;
            active_pixel <= 0;
        end
    end
endmodule
