`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2025 10:36:47
// Design Name: 
// Module Name: arithmetic_keypad_display
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
This module is responsible for rendering the keypad for the user to see. As per cursor_controller:
On a 96x64 (rows by columns), we should be rendering 13 symbols. To fit the screen, we will make each symbol
occupy 24x16. Accounting for a 1px padding, the symbol itself should occupy 22x14. The checkmark will take up
a full column by itself and thus occupy a 24x64. It should be centred.

7 8 9
4 5 6
1 2 3    ^ (checkmark)
0 . x

The symbols should be rendered on a white background with the symbols themselves being black. When hovered over,
the symbols should invert, becoming white and occupying a black background in their space.

On button press, this inversion should also happen aka flash for the user to also visually understand that their
input has been ingested.

If the user has previously inputted a decimal, then when hovering over the decimal, the decimal symbol
should be white on a red background, indicating that the user cannot input it again.

The module has been updated to support our ROM modules.
*/
module arithmetic_keypad_display(
    input clk,
    input [12:0]pixel_index,
    input [1:0]cursor_row,
    input [2:0]cursor_col,
    input has_decimal,
    output reg [15:0]oled_data
    );

    // OLED dimensions
    parameter WIDTH = 96;
    parameter HEIGHT = 64;

    // Extract pixel coordinates
    wire [6:0] x = pixel_index % WIDTH;
    wire [6:0] y = pixel_index / WIDTH;

    // Keypad layout constants
    parameter BUTTON_WIDTH = 24;
    parameter BUTTON_HEIGHT = 16;
    parameter KEYPAD_START_X = 0;
    parameter KEYPAD_START_Y = 0;
    parameter CHECKMARK_X = 72;

    // Colors
    parameter WHITE = 16'hFFFF;
    parameter BLACK = 16'h0000;
    parameter RED = 16'hF800;

    // Variables to determine button position
    wire [1:0] current_button_row = y / BUTTON_HEIGHT;
    wire [1:0] current_button_col = x / BUTTON_WIDTH;
    wire inside_button = (x < CHECKMARK_X) && (current_button_row < 4 && current_button_col < 3);
    wire inside_checkmark = (x >= CHECKMARK_X);
    reg [6:0] rel_x;
    reg [6:0] rel_y;


    // Selection and disabling logic
    wire is_selected_button = (inside_button && current_button_row == cursor_row && current_button_col == cursor_col);
    wire is_selected_checkmark = (inside_checkmark && cursor_col == 3'd3);
    wire is_decimal_button = (inside_button && current_button_row == 2'd3 && current_button_col == 2'd1);
    wire is_disabled_decimal = (is_decimal_button && has_decimal);

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
        if (inside_button) begin
            // Assign button character
            case({current_button_row, current_button_col})
                {2'd0, 2'd0}: button_char = 6'd7;  // 7 (ASCII offset)
                {2'd0, 2'd1}: button_char = 6'd8;  // 8
                {2'd0, 2'd2}: button_char = 6'd9;  // 9
                {2'd1, 2'd0}: button_char = 6'd4;  // 4
                {2'd1, 2'd1}: button_char = 6'd5;  // 5
                {2'd1, 2'd2}: button_char = 6'd6;  // 6
                {2'd2, 2'd0}: button_char = 6'd1;  // 1
                {2'd2, 2'd1}: button_char = 6'd2;  // 2
                {2'd2, 2'd2}: button_char = 6'd3;  // 3
                {2'd3, 2'd0}: button_char = 6'd0;  // 0
                {2'd3, 2'd1}: button_char = 6'd14; // . (decimal point)
                {2'd3, 2'd2}: button_char = 6'd38; // X (backspace)
                default: button_char = 6'd32;
            endcase

            rel_x = x % BUTTON_WIDTH;
            rel_y = y % BUTTON_HEIGHT;

            // Draw button border
            if (rel_x == 0 || rel_x == BUTTON_WIDTH - 1 || rel_y == 0 || rel_y ==  BUTTON_HEIGHT - 1) begin
                oled_data = BLACK;
            end
            else begin
                if (is_selected_button) begin
                    if (is_disabled_decimal) begin
                        oled_data = RED;
                    end
                    else begin
                        oled_data = BLACK;
                    end
                end
                else begin
                    oled_data = WHITE;
                end

                button_char_x = (current_button_col * BUTTON_WIDTH) + (BUTTON_WIDTH/2) - 4;
                button_char_y = (current_button_row * BUTTON_HEIGHT) + (BUTTON_HEIGHT/2) - 6;

                if (button_char_active) begin
                    oled_data = is_selected_button ? WHITE : BLACK;
                end
            end
        end
        else if (inside_checkmark) begin
            button_char = 6'd42;
            rel_x = x - CHECKMARK_X;

            // Border
            if (rel_x == 0 || rel_x == BUTTON_WIDTH - 1 || y == 0 || y == HEIGHT - 1) begin
                oled_data = BLACK;
            end
            else begin
                // Background color
                oled_data = is_selected_checkmark ? BLACK : WHITE;

                if (y >= 24 && y < 40) begin
                    button_char_x = CHECKMARK_X + 8;
                    button_char_y = 24;

                    if (button_char_active) begin
                        oled_data = is_selected_checkmark ? WHITE : BLACK;
                    end
                end
            end
        end
    end
endmodule
