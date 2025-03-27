`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2025 15:26:49
// Design Name: 
// Module Name: arithmetic_keypad_renderer
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
This module is responsible for choosing which keypad, the number or operand keypad, to render based on an is_operand_mode flag. It makes the decision as to which oled_data to render.
*/
module arithmetic_keypad_renderer(
    input clk,
    input [12:0]pixel_index,
    input [1:0]cursor_row_keypad,
    input [2:0]cursor_col_keypad,
    input [1:0]cursor_row_operand,
    input [1:0]cursor_col_operand,
    input has_decimal,
    input is_operand_mode,
    output reg [15:0]oled_data
    );

    // Output from keypad display module
    wire [15:0]keypad_data;

    // Output from operand display module
    wire [15:0]operand_data;

    // Instantiate both display modules
    arithmetic_keypad_display keypad(
        .clk(clk),
        .pixel_index(pixel_index),
        .cursor_row(cursor_row_keypad),
        .cursor_col(cursor_col_keypad),
        .has_decimal(has_decimal),
        .oled_data(keypad_data)
    );
    
    operand_display operand(
        .clk(clk),
        .pixel_index(pixel_index),
        .cursor_row(cursor_row_operand),
        .cursor_col(cursor_col_operand),
        .oled_data(operand_data)
    );
    
    // Select which display to show based on mode
    always @(*) begin
        if (is_operand_mode)
            oled_data = operand_data;
        else
            oled_data = keypad_data;
    end
endmodule
