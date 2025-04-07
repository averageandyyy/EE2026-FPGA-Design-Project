`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2025 15:06:43
// Design Name: 
// Module Name: operand_display
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
This module renders a 2x2 grid of operation buttons:
+ -
x /

The layout follows similar principles to keypad_display but with operation symbols instead
*/
module operand_display(
    input clk,
    input [12:0]pixel_index,
    input [1:0]cursor_row,
    input [1:0]cursor_col,
    output reg [15:0] oled_data
    );

    // OLED dimensions
    parameter WIDTH = 96;
    parameter HEIGHT = 64;
    
    // Calculate x and y coordinates from pixel_index
    wire [6:0] x = pixel_index % WIDTH;
    wire [5:0] y = pixel_index / WIDTH;
    
    // Operand layout constants
    parameter BUTTON_WIDTH = 32;
    parameter BUTTON_HEIGHT = 32;
    parameter KEYPAD_START_X = 16;
    parameter KEYPAD_START_Y = 0;
    
    // Colors
    parameter WHITE = 16'hFFFF;
    parameter BLACK = 16'h0000;
    
    // Variables to determine if the current pixel is inside a button
    reg inside_button;
    reg [1:0] current_button_row;
    reg [1:0] current_button_col;
    reg [7:0] button_char;

    // Loop to determine if pixel is within a button and what button that is
    always @ (*) begin
        // Default values
        inside_button = 0;
        current_button_row = 2'b11;
        current_button_col = 2'b11;
        button_char = 8'h00;

        // Calculate which button the pixel is in
        current_button_row = (y - KEYPAD_START_Y) / BUTTON_HEIGHT;
        current_button_col = (x - KEYPAD_START_X) / BUTTON_WIDTH;

        // Check if pixel is within button bounds (2x2 grid)
        if (x >= KEYPAD_START_X && x < KEYPAD_START_X + 2 * BUTTON_WIDTH &&
            y >= KEYPAD_START_Y && y < KEYPAD_START_Y + 2 * BUTTON_HEIGHT) begin

            inside_button = 1;

            // Assign character based on position
            case({current_button_row, current_button_col})
                4'b00_00: button_char = "+";
                4'b00_01: button_char = "-";
                4'b01_00: button_char = "*";
                4'b01_01: button_char = "/";
            endcase
        end
    end

    // Determine if button is currently selected (hovered over)
    wire is_selected_button = (inside_button && current_button_row == cursor_row && current_button_col == cursor_col);

    integer rel_x;
    integer rel_y;
    reg [15:0] bg_color;

    // Loop to render pixel data
    always @ (*) begin
        // Default white background
        oled_data = WHITE;

        if (inside_button) begin
            // Calculate position within button
            rel_x = (x - KEYPAD_START_X) % BUTTON_WIDTH;
            rel_y = (y - KEYPAD_START_Y) % BUTTON_HEIGHT;

            // Drawing button border (1px)
            if (rel_x == 0 || rel_x == BUTTON_WIDTH - 1 || rel_y == 0 || rel_y == BUTTON_HEIGHT - 1) begin
                oled_data = BLACK;
            end

            // Drawing inner button area
            else begin
                // Choosing background color depending on selection status
                bg_color = is_selected_button ? BLACK : WHITE;

                // Check if inside character area
                if (rel_x >= 10 && rel_x < 22 && rel_y >= 10 && rel_y < 22) begin
                    if (should_draw_pixel_for_operator(button_char, rel_x - 10, rel_y - 10)) begin
                        // Choosing symbol color based on selection status
                        oled_data = (bg_color == WHITE) ? BLACK : WHITE;
                    end
                    else begin
                        oled_data = bg_color;
                    end
                end
                else begin
                    oled_data = bg_color;
                end
            end
        end
    end

    // Function to determine if a pixel should be drawn for an operator
    function should_draw_pixel_for_operator;
        input [7:0] op_char;
        input [4:0] x; // 0-11
        input [4:0] y; // 0-11
        begin
            case(op_char)
                "+": begin // Addition symbol
                    if ((x == 5 || x == 6) || (y == 5 || y == 6))
                        should_draw_pixel_for_operator = 1;
                    else
                        should_draw_pixel_for_operator = 0;
                end
                
                "-": begin // Subtraction symbol
                    if (y == 5 || y == 6)
                        should_draw_pixel_for_operator = 1;
                    else
                        should_draw_pixel_for_operator = 0;
                end
                
                "*": begin // Multiplication symbol (×)
                    if ((x == y || x == 11-y) && (x >= 2 && x <= 9 && y >= 2 && y <= 9))
                        should_draw_pixel_for_operator = 1;
                    else
                        should_draw_pixel_for_operator = 0;
                end
                
                "/": begin // Division symbol (÷)
                    if (y == 5 || y == 6) // Horizontal line
                        should_draw_pixel_for_operator = 1;
                    else if ((x >= 4 && x <= 7) && (y >= 1 && y <= 3 || y >= 8 && y <= 10)) // Dots
                        should_draw_pixel_for_operator = 1;
                    else
                        should_draw_pixel_for_operator = 0;
                end
                
                default: should_draw_pixel_for_operator = 0;
            endcase
        end
    endfunction

endmodule
