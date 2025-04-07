`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2025 11:41:03
// Design Name: 
// Module Name: arithmetic_result_renderer
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


module arithmetic_result_renderer(
    input clk,
    input [12:0] pixel_index,
    input signed [31:0] result,      // Q16.16 fixed-point result to display
    input is_operand_mode,           // Current calculator mode
    output reg [15:0] oled_data
    );
    
    // OLED dimensions
    parameter WIDTH = 96;
    parameter HEIGHT = 64;
    
    // Calculate x and y coordinates
    wire [6:0] x = pixel_index % WIDTH;
    wire [5:0] y = pixel_index / WIDTH;
    
    // Colors
    parameter WHITE = 16'hFFFF;
    parameter BLACK = 16'h0000;
    parameter BLUE = 16'h001F;
    parameter GREEN = 16'h07E0;
    
    // Result formatting
    wire is_negative = (result < 0);
    wire [31:0] abs_result = is_negative ? -result : result;
    wire [15:0] integer_part = abs_result >> 16;        // Upper 16 bits
    wire [15:0] fraction_part = abs_result & 16'hFFFF;  // Lower 16 bits
    
    // Extract digits for display
    wire [3:0] digit0 = integer_part % 10;
    wire [3:0] digit1 = (integer_part / 10) % 10;
    wire [3:0] digit2 = (integer_part / 100) % 10;
    wire [3:0] digit3 = (integer_part / 1000) % 10;
    
    wire [3:0] frac0 = (fraction_part * 10 / 65536) % 10;
    wire [3:0] frac1 = (fraction_part * 100 / 65536) % 10;
    wire [3:0] frac2 = (fraction_part * 1000 / 65536) % 10;
    
    // Character rendering positions
    parameter LABEL_X = 10;
    parameter LABEL_Y = 10;
    parameter VALUE_X = 10;
    parameter VALUE_Y = 30;
    
    // Function to determine if a pixel should be drawn for a digit
    function should_draw_pixel_for_digit;
        input [3:0] digit;
        input [3:0] x_pos;
        input [3:0] y_pos;
        begin
            // Default is not to draw
            should_draw_pixel_for_digit = 0;
            
            case(digit)
                0: begin // Draw "0"
                    if ((y_pos == 0 || y_pos == 11) && x_pos > 1 && x_pos < 6) // Top and bottom
                        should_draw_pixel_for_digit = 1;
                    else if ((x_pos == 1 || x_pos == 6) && y_pos > 0 && y_pos < 11) // Left and right sides
                        should_draw_pixel_for_digit = 1;
                end
                
                1: begin // Draw "1"
                    if (x_pos == 4) // Vertical line
                        should_draw_pixel_for_digit = 1;
                    else if (y_pos == 11 && x_pos >= 2 && x_pos <= 6) // Base
                        should_draw_pixel_for_digit = 1;
                    else if (x_pos == 3 && y_pos == 1) // Top-left
                        should_draw_pixel_for_digit = 1;
                end
                
                2: begin // Draw "2"
                    if ((y_pos == 0 || y_pos == 11 || y_pos == 6) && x_pos > 1 && x_pos < 6)
                        should_draw_pixel_for_digit = 1;
                    else if (x_pos == 6 && y_pos > 0 && y_pos < 6)
                        should_draw_pixel_for_digit = 1;
                    else if (x_pos == 1 && y_pos > 6 && y_pos < 11)
                        should_draw_pixel_for_digit = 1;
                end
                
                3: begin // Draw "3"
                    if ((y_pos == 0 || y_pos == 11 || y_pos == 6) && x_pos > 1 && x_pos < 6)
                        should_draw_pixel_for_digit = 1;
                    else if (x_pos == 6 && ((y_pos > 0 && y_pos < 6) || (y_pos > 6 && y_pos < 11)))
                        should_draw_pixel_for_digit = 1;
                end
                
                4: begin // Draw "4"
                    if (x_pos == 1 && y_pos < 7)
                        should_draw_pixel_for_digit = 1;
                    else if (x_pos == 6)
                        should_draw_pixel_for_digit = 1;
                    else if (y_pos == 6 && x_pos > 1 && x_pos < 6)
                        should_draw_pixel_for_digit = 1;
                end
                
                5: begin // Draw "5"
                    if ((y_pos == 0 || y_pos == 11 || y_pos == 6) && x_pos > 1 && x_pos < 6)
                        should_draw_pixel_for_digit = 1;
                    else if (x_pos == 1 && y_pos > 0 && y_pos < 6)
                        should_draw_pixel_for_digit = 1;
                    else if (x_pos == 6 && y_pos > 6 && y_pos < 11)
                        should_draw_pixel_for_digit = 1;
                end
                
                6: begin // Draw "6"
                    if ((y_pos == 0 || y_pos == 11 || y_pos == 6) && x_pos > 1 && x_pos < 6)
                        should_draw_pixel_for_digit = 1;
                    else if (x_pos == 1 && y_pos > 0 && y_pos < 11)
                        should_draw_pixel_for_digit = 1;
                    else if (x_pos == 6 && y_pos > 6 && y_pos < 11)
                        should_draw_pixel_for_digit = 1;
                end
                
                7: begin // Draw "7"
                    if (y_pos == 0 && x_pos > 1 && x_pos < 6)
                        should_draw_pixel_for_digit = 1;
                    else if (x_pos == 6 && y_pos > 0)
                        should_draw_pixel_for_digit = 1;
                end
                
                8: begin // Draw "8"
                    if ((y_pos == 0 || y_pos == 11 || y_pos == 6) && x_pos > 1 && x_pos < 6)
                        should_draw_pixel_for_digit = 1;
                    else if ((x_pos == 1 || x_pos == 6) && ((y_pos > 0 && y_pos < 6) || (y_pos > 6 && y_pos < 11)))
                        should_draw_pixel_for_digit = 1;
                end
                
                9: begin // Draw "9"
                    if ((y_pos == 0 || y_pos == 11 || y_pos == 6) && x_pos > 1 && x_pos < 6)
                        should_draw_pixel_for_digit = 1;
                    else if (x_pos == 1 && y_pos > 0 && y_pos < 6)
                        should_draw_pixel_for_digit = 1;
                    else if (x_pos == 6 && ((y_pos > 0 && y_pos < 6) || (y_pos > 6 && y_pos < 11)))
                        should_draw_pixel_for_digit = 1;
                end
            endcase
        end
    endfunction
    
    reg [3:0] rel_x;
    reg [3:0] rel_y;
    // Function to check if we should render a specific character at a location
    function should_draw_char;
        input [7:0] char;
        input [6:0] char_x;
        input [5:0] char_y;
        input [6:0] curr_x;
        input [5:0] curr_y;
        begin
            should_draw_char = 0;
            
            // Check if current pixel is within character area
            if (curr_x >= char_x && curr_x < char_x+8 && curr_y >= char_y && curr_y < char_y+12) begin
                // Calculate relative position within character
                rel_x = curr_x - char_x;
                rel_y = curr_y - char_y;
                
                // Handle different character types
                if (char >= "0" && char <= "9") begin
                    // Digit 0-9
                    should_draw_char = should_draw_pixel_for_digit(char - "0", rel_x, rel_y);
                end
                else if (char == ".") begin
                    // Decimal point
                    if (rel_x >= 3 && rel_x <= 5 && rel_y >= 9 && rel_y <= 11)
                        should_draw_char = 1;
                end
                else if (char == "-") begin
                    // Negative sign
                    if (rel_y >= 5 && rel_y <= 7 && rel_x >= 2 && rel_x <= 6)
                        should_draw_char = 1;
                end
                else if (char == "R") begin
                    // Letter R (simplified)
                    if ((rel_x == 2 || rel_x == 3) && rel_y >= 2 && rel_y <= 10)
                        should_draw_char = 1;
                    else if ((rel_y == 2 || rel_y == 6) && rel_x >= 2 && rel_x <= 5)
                        should_draw_char = 1;
                    else if (rel_x == 6 && rel_y >= 3 && rel_y <= 5)
                        should_draw_char = 1;
                    else if ((rel_y - rel_x == 3) && rel_y >= 7 && rel_y <= 10)
                        should_draw_char = 1;
                end
                else if (char == "E") begin
                    // Letter E
                    if (rel_x == 2 && rel_y >= 2 && rel_y <= 10)
                        should_draw_char = 1;
                    else if ((rel_y == 2 || rel_y == 6 || rel_y == 10) && rel_x >= 2 && rel_x <= 6)
                        should_draw_char = 1;
                end
                else if (char == "S") begin
                    // Letter S
                    if ((rel_y == 2 || rel_y == 6 || rel_y == 10) && rel_x >= 2 && rel_x <= 6)
                        should_draw_char = 1;
                    else if (rel_x == 2 && rel_y >= 3 && rel_y <= 5)
                        should_draw_char = 1;
                    else if (rel_x == 6 && rel_y >= 7 && rel_y <= 9)
                        should_draw_char = 1;
                end
                else if (char == "U") begin
                    // Letter U
                    if ((rel_x == 2 || rel_x == 6) && rel_y >= 2 && rel_y <= 9)
                        should_draw_char = 1;
                    else if (rel_y == 10 && rel_x >= 3 && rel_x <= 5)
                        should_draw_char = 1;
                end
                else if (char == "L") begin
                    // Letter L
                    if (rel_x == 2 && rel_y >= 2 && rel_y <= 10)
                        should_draw_char = 1;
                    else if (rel_y == 10 && rel_x >= 2 && rel_x <= 6)
                        should_draw_char = 1;
                end
                else if (char == "T") begin
                    // Letter T
                    if (rel_y == 2 && rel_x >= 2 && rel_x <= 6)
                        should_draw_char = 1;
                    else if (rel_x == 4 && rel_y >= 2 && rel_y <= 10)
                        should_draw_char = 1;
                end
                else if (char == ":") begin
                    // Colon
                    if ((rel_y == 4 || rel_y == 8) && rel_x == 4)
                        should_draw_char = 1;
                end
            end
        end
    endfunction
    
    // Render OLED output
    always @(*) begin
        // Default white background
        oled_data = WHITE;
        
        // Draw border
        if (x == 0 || x == WIDTH-1 || y == 0 || y == HEIGHT-1) begin
            oled_data = BLACK;
        end
        
        // Draw title bar
        else if (y < 15) begin
            if (y == 14) begin
                oled_data = BLACK; // Bottom border of title
            end
            else if (should_draw_char("R", 20, 5, x, y) || 
                    should_draw_char("E", 28, 5, x, y) || 
                    should_draw_char("S", 36, 5, x, y) || 
                    should_draw_char("U", 44, 5, x, y) || 
                    should_draw_char("L", 52, 5, x, y) || 
                    should_draw_char("T", 60, 5, x, y) || 
                    should_draw_char(":", 68, 5, x, y)) begin
                oled_data = BLUE;
            end
        end
        
        // Draw main result area
        else if (y >= 25 && y < 45) begin
            // Handle negative sign
            if (is_negative && should_draw_char("-", 10, 30, x, y))
                oled_data = BLACK;
                
            // Draw integer part based on number of digits
            if (integer_part < 10) begin
                // Single digit
                if (should_draw_char(digit0 + "0", 20, 30, x, y))
                    oled_data = BLACK;
            end
            else if (integer_part < 100) begin
                // Two digits
                if (should_draw_char(digit1 + "0", 12, 30, x, y) || 
                    should_draw_char(digit0 + "0", 20, 30, x, y))
                    oled_data = BLACK;
            end
            else if (integer_part < 1000) begin
                // Three digits
                if (should_draw_char(digit2 + "0", 4, 30, x, y) || 
                    should_draw_char(digit1 + "0", 12, 30, x, y) || 
                    should_draw_char(digit0 + "0", 20, 30, x, y))
                    oled_data = BLACK;
            end
            else begin
                // Four digits
                if (should_draw_char(digit3 + "0", 4, 30, x, y) || 
                    should_draw_char(digit2 + "0", 12, 30, x, y) || 
                    should_draw_char(digit1 + "0", 20, 30, x, y) || 
                    should_draw_char(digit0 + "0", 28, 30, x, y))
                    oled_data = BLACK;
            end
            
            // Draw decimal point and fractional part if non-zero
            if (fraction_part > 0) begin
                if (should_draw_char(".", 28, 30, x, y) ||
                    should_draw_char(frac0 + "0", 36, 30, x, y) ||
                    should_draw_char(frac1 + "0", 44, 30, x, y) ||
                    should_draw_char(frac2 + "0", 52, 30, x, y))
                    oled_data = BLACK;
            end
        end
        
        // Draw mode indicator
        else if (y >= 50 && y < 60) begin
            if (x >= 10 && x < 86 && y >= 50 && y < 56) begin
                if (is_operand_mode) begin
                    if ((x - 10) % 3 == 0)
                        oled_data = GREEN; // "Select Operation" indicator
                end else begin
                    if ((x - 10) % 4 == 0)
                        oled_data = BLUE; // "Enter Number" indicator
                end
            end
        end
    end
endmodule
