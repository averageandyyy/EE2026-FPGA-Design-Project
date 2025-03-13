`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2025 19:46:31
// Design Name: 
// Module Name: keypad_display
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
*/
module keypad_display(
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

    // Obtain x and y coordinates
    wire [6:0]x = pixel_index % WIDTH;
    wire [6:0]y = pixel_index / WIDTH;

    // Keypad layout constants
    parameter BUTTON_WIDTH = 24;
    parameter BUTTON_HEIGHT = 16;
    parameter KEYPAD_START_X = 0;
    parameter KEYPAD_START_Y = 0;
    parameter CHECKMARK_X = 72;

    // Colours
    parameter WHITE = 16'hFFFF;
    parameter BLACK = 16'h0000;
    parameter RED = 16'hF800;

    // Variables to track which button the pixel is currently at
    reg inside_button;
    reg inside_checkmark;
    reg [1:0]current_button_row;
    reg [1:0]current_button_col;
    reg [7:0]button_char;

    // Loop to determine if a pixel is within a button and what button that is
    always @ (*) begin
        // Resetting values
        inside_button = 0;
        inside_checkmark = 0;
        current_button_row = 2'b11;
        current_button_col = 2'b11;
        button_char = 8'h00;

        // Check if pixel is in regular keypad area
        if (x < CHECKMARK_X) begin
            // Calculate the button position that pixel is currently in
            current_button_row = y / BUTTON_HEIGHT;
            current_button_col = x / BUTTON_WIDTH;

            // Validate button coordinates (main keypad)
            if (current_button_row < 4 && current_button_col < 3) begin
                inside_button = 1;

                // Assign character to render based on position (Verilog supports ASCII chars!)
                if (current_button_row == 0) begin
                    case(current_button_col)
                        0: button_char = "7";
                        1: button_char = "8";
                        2: button_char = "9";
                    endcase
                end
                else if (current_button_row == 1) begin
                    case(current_button_col)
                        0: button_char = "4";
                        1: button_char = "5";
                        2: button_char = "6";
                    endcase
                end
                else if (current_button_row == 2) begin
                    case(current_button_col)
                        0: button_char = "1";
                        1: button_char = "2";
                        2: button_char = "3";
                    endcase
                end
                else if (current_button_row == 3) begin
                    case(current_button_col)
                        0: button_char = "0";
                        1: button_char = ".";
                        2: button_char = "x";
                    endcase
                end
            end
        end
        else begin
            inside_checkmark = 1;
        end
    end

    // Variables to check what symbol the user is currently hovering over
    wire is_selected_button = (inside_button && current_button_row == cursor_row && current_button_col == cursor_col);
    wire is_selected_checkmark = (inside_checkmark && cursor_col == 3'd3);

    // Variables to change how the decimal button is rendered
    wire is_decimal_button = (inside_button && current_button_row == 2'd3 && current_button_col == 2'd1);
    wire is_disabled_decimal = (is_decimal_button && is_selected_button && has_decimal);

    integer rel_x;
    integer rel_y;
    reg [15:0] bg_color;

    // Loop to render pixel data based on position
    always @ (*) begin
        // Default background
        oled_data = WHITE;

        if (inside_button) begin
            // Calculate position within button for rendering
            rel_x = x % BUTTON_WIDTH;
            rel_y = y % BUTTON_HEIGHT;

            // Drawing button border (1px)
            if (rel_x == 0 || rel_x == BUTTON_WIDTH - 1 || rel_y == 0 || rel_y == BUTTON_HEIGHT - 1) begin
                oled_data = BLACK;
            end

            // Drawing inner button area
            else if (rel_x > 0 && rel_x < BUTTON_WIDTH - 1 && rel_y > 0 && rel_y < BUTTON_HEIGHT - 1) begin
                // Determine background color first (applies to character background and non-character area)
                if (is_selected_button) begin
                    if (is_disabled_decimal)
                        bg_color = RED; // Red for disabled decimal
                    else
                        bg_color = BLACK; // Black for selected button
                end else begin
                    bg_color = WHITE; // White for normal button
                end

                // Check if within bounds to render character (14x10)
                if (rel_x >= 6 && rel_x < 20 && rel_y >= 3 && rel_y < 13) begin
                    // Additonal check if pixel is on the symbol/character itself
                    if (should_draw_pixel_for_char(button_char, rel_x - 6, rel_y - 3)) begin
                        // Character pixel - inverse of background
                        oled_data = (bg_color == WHITE) ? BLACK : WHITE;
                    end
                    else begin
                        // Symbol background
                        oled_data = bg_color;
                    end
                end
                // Other background
                else begin
                    oled_data = bg_color;
                end
            end
        end

        else if (inside_checkmark) begin
            // Drawing checkmark in rightmost column
            // Checkmark is to be centred
            rel_x = x - CHECKMARK_X;
            
            // Border for checkmark area
            if (rel_x == 0 || rel_x == BUTTON_WIDTH - 1 || y == 0 || y == HEIGHT - 1) begin
                oled_data = BLACK;
            end

            // Checkmark symbol
            else if (y >= 20 && y < 44) begin
                if (should_draw_checkmark(rel_x, y - 20)) begin
                    if (is_selected_checkmark) begin
                        oled_data = WHITE;
                    end
                    else begin
                        oled_data = BLACK;
                    end
                end
                else begin
                    if (is_selected_checkmark) begin
                        oled_data = BLACK;
                    end
                    else begin
                        oled_data = WHITE;
                    end
                end
            end
            else begin
                if (is_selected_checkmark) begin
                    oled_data = BLACK;
                end
                else begin
                    oled_data = WHITE;
                end
            end
        end
    end

    // Function to determine if a pixel should be part of the checkmark
    function should_draw_checkmark;
        input [5:0] x; // 0-23
        input [5:0] y; // 0-23
        begin
            // Create a simple checkmark shape
            if ((x >= 6 && x <= 10 && y >= 12 && y <= 18 && x + y >= 20 && x + y <= 26) || // Short arm
                (x >= 10 && x <= 18 && y >= 6 && y <= 14 && y <= 22-x)) // Long arm
                should_draw_checkmark = 1;
            else
                should_draw_checkmark = 0;
        end
    endfunction
    
    // Function to determine if a pixel should be drawn for a given character
    function should_draw_pixel_for_char;
        input [7:0] char;
        input [5:0] x; // 0-13
        input [5:0] y; // 0-9
        begin
            // Default to not drawing
            should_draw_pixel_for_char = 0;
            
            case(char)
                "0": begin // Draw "0"
                    if ((y == 0 || y == 9) && x > 2 && x < 11) // Top and bottom
                        should_draw_pixel_for_char = 1;
                    else if ((x == 2 || x == 11) && y > 0 && y < 9) // Left and right sides
                        should_draw_pixel_for_char = 1;
                    else if (y > 2 && y < 7 && x > 2 && x < 11 && (x + y == 14 || x + y == 15)) // Diagonal
                        should_draw_pixel_for_char = 1;
                end
                
                "1": begin // Draw "1"
                    if (x == 7) // Vertical line
                        should_draw_pixel_for_char = 1;
                    else if (y == 9 && x >= 4 && x <= 10) // Base
                        should_draw_pixel_for_char = 1;
                    else if (x == 6 && y == 1) // Top-left diagonal
                        should_draw_pixel_for_char = 1;
                    else if (x == 5 && y == 2) // Top-left diagonal
                        should_draw_pixel_for_char = 1;
                end
                
                "2": begin // Draw "2"
                    if (y == 0 && x > 2 && x < 11) // Top horizontal
                        should_draw_pixel_for_char = 1;
                    else if (y == 9 && x >= 2 && x <= 11) // Bottom horizontal
                        should_draw_pixel_for_char = 1;
                    else if (y == 5 && x >= 2 && x <= 9) // Middle horizontal
                        should_draw_pixel_for_char = 1;
                    else if (x == 11 && y > 0 && y < 5) // Upper right
                        should_draw_pixel_for_char = 1;
                    else if (x == 2 && y > 5 && y < 9) // Lower left
                        should_draw_pixel_for_char = 1;
                end
                
                "3": begin // Draw "3"
                    if ((y == 0 || y == 9 || y == 4) && x > 2 && x < 11) // Horizontals
                        should_draw_pixel_for_char = 1;
                    else if (x == 11 && (y < 4 || (y > 4 && y < 9))) // Right side
                        should_draw_pixel_for_char = 1;
                end
                
                "4": begin // Draw "4"
                    if (x == 3 && y < 6) // Upper left vertical
                        should_draw_pixel_for_char = 1;
                    else if (x == 10 && y != 9) // Right vertical
                        should_draw_pixel_for_char = 1;
                    else if (y == 5 && x > 2 && x < 11) // Middle horizontal
                        should_draw_pixel_for_char = 1;
                end
                
                "5": begin // Draw "5"
                    if ((y == 0 || y == 4 || y == 9) && x > 2 && x < 11) // Horizontals
                        should_draw_pixel_for_char = 1;
                    else if (x == 2 && y > 0 && y < 5) // Upper left
                        should_draw_pixel_for_char = 1;
                    else if (x == 11 && y > 4 && y < 9) // Lower right
                        should_draw_pixel_for_char = 1;
                end
                
                "6": begin // Draw "6"
                    if ((y == 0 || y == 4 || y == 9) && x > 2 && x < 11) // Horizontals
                        should_draw_pixel_for_char = 1;
                    else if (x == 2 && y > 0 && y < 9) // Left side
                        should_draw_pixel_for_char = 1;
                    else if (x == 11 && y > 4 && y < 9) // Lower right
                        should_draw_pixel_for_char = 1;
                end
                
                "7": begin // Draw "7"
                    if (y == 0) // Top horizontal
                        should_draw_pixel_for_char = 1;
                    else if (x == 11 && y < 4) // Upper right
                        should_draw_pixel_for_char = 1;
                    else if ((x == 9 && y == 4) || (x == 8 && y == 5) || 
                            (x == 7 && y == 6) || (x == 6 && y == 7) || 
                            (x == 5 && y == 8) || (x == 4 && y == 9)) // Diagonal
                        should_draw_pixel_for_char = 1;
                end
                
                "8": begin // Draw "8"
                    if ((y == 0 || y == 4 || y == 9) && x > 2 && x < 11) // Horizontals
                        should_draw_pixel_for_char = 1;
                    else if ((x == 2 || x == 11) && ((y > 0 && y < 4) || (y > 5 && y < 9))) // Verticals
                        should_draw_pixel_for_char = 1;
                end
                
                "9": begin // Draw "9"
                    if ((y == 0 || y == 4 || y == 9) && x > 2 && x < 11) // Horizontals
                        should_draw_pixel_for_char = 1;
                    else if (x == 2 && y > 0 && y < 4) // Upper left
                        should_draw_pixel_for_char = 1;
                    else if (x == 11 && y > 0 && y < 9) // Right side
                        should_draw_pixel_for_char = 1;
                end
                
                ".": begin // Draw decimal point
                    if (x >= 4 && x <= 7 && y >= 7 && y <= 9)
                        should_draw_pixel_for_char = 1;
                end
                
                "x": begin // Draw backspace symbol "x"
                    if ((x == y || x == 9-y) && x >= 0 && x <= 9)
                        should_draw_pixel_for_char = 1;
                end
            endcase
        end
    endfunction
endmodule
