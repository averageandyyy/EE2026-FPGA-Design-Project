`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2025 09:07:27
// Design Name: 
// Module Name: arithmetic_module
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


module arithmetic_module(
    // Clock inputs
    input clk_6p25MHz,
    input clk_1kHz,

    // Button inputs
    input btnC, btnU, btnD, btnL, btnR,

    // Expose flags for module control
    input reset,
    input is_arithmetic_mode,

    // Mouse inputs (for future compatibility) KIV Daniel
    input [6:0] xpos,
    input [6:0] ypos,
    input use_mouse,
    input mouse_left,
    input mouse_middle,

    // OLED outputs
    input [12:0] one_pixel_index,
    input [12:0] two_pixel_index,
    output [15:0] one_oled_data,
    output [15:0] two_oled_data,

    output overflow_flag
    );

    // Internal signals
    wire [1:0] cursor_row_keypad;
    wire [2:0] cursor_col_keypad;
    wire [1:0] cursor_row_operand;
    wire [1:0] cursor_col_operand;
    wire keypad_btn_pressed;
    wire operand_btn_pressed;
    wire [3:0] selected_keypad_value;
    wire [1:0] selected_operand_value;
    wire input_complete;
    wire signed [31:0] fp_value;
    wire signed [31:0] result;
    wire [1:0] operation_done;
    wire [31:0] bcd_value;
    wire [3:0] decimal_pos;
    wire has_decimal;
    wire is_operand_mode;
    wire [3:0] input_index;

    // Cursor controller for handling user input
    arithmetic_cursor_controller cursor_ctrl(
        .clk(clk_1kHz),
        .reset(reset || !is_arithmetic_mode),
        .btnC(is_arithmetic_mode ? btnC : 1'b0),  // Only process buttons when in arithmetic mode
        .btnU(is_arithmetic_mode ? btnU : 1'b0),
        .btnD(is_arithmetic_mode ? btnD : 1'b0),
        .btnL(is_arithmetic_mode ? btnL : 1'b0),
        .btnR(is_arithmetic_mode ? btnR : 1'b0),
        .is_operand_mode(is_operand_mode),
        .cursor_row_keypad(cursor_row_keypad),
        .cursor_col_keypad(cursor_col_keypad),
        .cursor_row_operand(cursor_row_operand),
        .cursor_col_operand(cursor_col_operand),
        .keypad_btn_pressed(keypad_btn_pressed),
        .operand_btn_pressed(operand_btn_pressed),
        .keypad_selected_value(selected_keypad_value),
        .operand_selected_value(selected_operand_value)
    );

    // BCD to fixed-point converter
    unified_input_bcd_to_fp_builder input_builder(
        .clk(clk_1kHz),
        .keypad_btn_pressed(keypad_btn_pressed),
        .selected_keypad_value(selected_keypad_value),
        .is_active_mode(!is_operand_mode && is_arithmetic_mode), // Active when in keypad input mode
        .reset(reset || !is_arithmetic_mode),
        .enable_negative(0), // Arithmetic module doesn't use negative key
        .enable_backspace(1), // Arithmetic module uses backspace functionality
        .has_decimal(has_decimal),
        .has_negative(0), // Not used
        .input_index(input_index),
        .fp_value(fp_value),
        .bcd_value(bcd_value),
        .input_complete(input_complete),
        .decimal_pos(decimal_pos)
    );

    // Arithmetic calculation backend
    arithmetic_backend backend(
        .clk(clk_1kHz),
        .reset(reset || !is_arithmetic_mode),
        .input_complete(input_complete),
        .input_fp_value(fp_value),
        .operand_btn_pressed(operand_btn_pressed),
        .selected_operand_value(selected_operand_value),
        .is_operand_mode(is_operand_mode),
        .result(result),
        .current_operation(),
        .operation_done(operation_done),
        .overflow_flag(overflow_flag)
    );

    // Keypad renderer (first OLED)
    arithmetic_keypad_renderer keypad_renderer(
        .clk(clk_6p25MHz),
        .pixel_index(one_pixel_index),
        .cursor_row_keypad(cursor_row_keypad),
        .cursor_col_keypad(cursor_col_keypad),
        .cursor_row_operand(cursor_row_operand),
        .cursor_col_operand(cursor_col_operand),
        .has_decimal(has_decimal),
        .is_operand_mode(is_operand_mode),
        .oled_data(one_oled_data)
    );

    // Result/Input renderer (second OLED)
    arithmetic_input_result_renderer input_result_renderer(
        .clk(clk_6p25MHz),
        .pixel_index(two_pixel_index),
        .result(result),
        .is_operand_mode(is_operand_mode),
        .bcd_value(bcd_value),
        .decimal_pos(decimal_pos),
        .input_index(input_index),
        .has_decimal(has_decimal),
        .oled_data(two_oled_data)
    );

endmodule
