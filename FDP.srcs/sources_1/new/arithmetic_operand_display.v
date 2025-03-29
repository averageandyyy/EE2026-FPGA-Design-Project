`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2025 11:18:21
// Design Name: 
// Module Name: arithmetic_operand_display
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


/*
This module is responsible for rendering the operand selection grid for the user to see.
On a 96x64 (width by height), we should be rendering 4 symbols in a 2x2 grid.
Each symbol occupies 48x32. Accounting for 1px padding, the symbol itself should occupy 46x30.

+ -
× ÷

The symbols should be rendered on a white background with the symbols themselves being black.
When hovered over, the symbols should invert, becoming white and occupying a black background.

The module uses the ROM-based sprite rendering approach for consistency.
*/
module arithmetic_operand_display(
    input clk,
    input [12:0]pixel_index,
    input [1:0]cursor_row,
    input [1:0]cursor_col,
    output reg [15:0]oled_data
    );

    // OLED dimensions
    parameter WIDTH = 96;
    parameter HEIGHT = 64;

    // Extract pixel coordinates
    wire [6:0] x = pixel_index % WIDTH;
    wire [5:0] y = pixel_index / WIDTH;

    // Operand layout constants
    parameter BUTTON_WIDTH = 48;
    parameter BUTTON_HEIGHT = 32;

    // Colors
    parameter WHITE = 16'hFFFF;
    parameter BLACK = 16'h0000;

    // Variables to determine button position
    wire [1:0] current_button_row = y / BUTTON_HEIGHT;
    wire [1:0] current_button_col = x / BUTTON_WIDTH;
    wire inside_button = (current_button_row < 2 && current_button_col < 2);
    reg [6:0] rel_x;
    reg [5:0] rel_y;

    // Selection logic
    wire is_selected_button = (inside_button && current_button_row == cursor_row && current_button_col == cursor_col);

    // Sprite rendering outputs
    wire [15:0] button_char_data;
    wire button_char_active;
    reg [5:0] button_char;
    
    // Sprite character positions
    reg [6:0] button_char_x;
    reg [5:0] button_char_y;

    // Button character renderer
    sprite_renderer_optimized button_renderer(
        .clk(clk),
        .pixel_index(pixel_index),
        .character(button_char),
        .start_x(button_char_x),
        .start_y(button_char_y),
        .colour(is_selected_button ? WHITE : BLACK), // Invert colors when selected
        .oled_data(button_char_data),
        .active_pixel(button_char_active)
    );

    always @ (*) begin
        // Default white background
        oled_data = WHITE;

        if (inside_button) begin
            // Assign button character
            case({current_button_row, current_button_col})
                {2'd0, 2'd0}: button_char = 6'd10;  // + (plus)
                {2'd0, 2'd1}: button_char = 6'd11;  // - (minus)
                {2'd1, 2'd0}: button_char = 6'd12;  // × (multiply)
                {2'd1, 2'd1}: button_char = 6'd13;  // ÷ (divide)
                default: button_char = 6'd32;       // space
            endcase

            rel_x = x % BUTTON_WIDTH;
            rel_y = y % BUTTON_HEIGHT;

            // Draw button border
            if (rel_x == 0 || rel_x == BUTTON_WIDTH - 1 || rel_y == 0 || rel_y == BUTTON_HEIGHT - 1) begin
                oled_data = BLACK;
            end
            else begin
                // Set background color based on selection
                oled_data = is_selected_button ? BLACK : WHITE;
                
                // Position character in center of button
                button_char_x = (current_button_col * BUTTON_WIDTH) + (BUTTON_WIDTH/2) - 4;
                button_char_y = (current_button_row * BUTTON_HEIGHT) + (BUTTON_HEIGHT/2) - 6;

                // Draw character if active
                if (button_char_active) begin
                    oled_data = is_selected_button ? WHITE : BLACK;
                end
            end
        end
        
        // Draw grid dividers
        if (x == WIDTH/2 || y == HEIGHT/2) begin
            oled_data = BLACK;
        end
    end
endmodule
