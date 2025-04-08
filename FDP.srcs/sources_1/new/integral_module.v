`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2025 13:50:20
// Design Name: 
// Module Name: integral_module
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


module integral_module(
    // Clock inputs
    input clk_6p25MHz,
    input clk_1kHz,

    // Button inputs
    input btnC, btnU, btnD, btnL, btnR,

    // Module control flags
    input reset,
    input is_integral_mode,

    // Polynomial coefficients
    input signed [31:0] coeff_a,   
    input signed [31:0] coeff_b,   
    input signed [31:0] coeff_c,   
    input signed [31:0] coeff_d,   

    // OLED outputs
    input [12:0] one_pixel_index,
    input [12:0] two_pixel_index,
    output [15:0] one_oled_data,
    output [15:0] two_oled_data,

    // Expose user input bounds for use in graph module (KIV WeiHao)       
    output signed [31:0] integration_lower_bound,
    output signed [31:0] integration_upper_bound
    );

    // Internal signals for module coordination
    wire is_integral_input_mode;
    wire is_input_a;
    wire is_input_b;
    wire is_complete;
    wire input_complete;
    wire is_computation_complete;
    
    // Integration bounds
    wire signed [31:0] a_lower;
    wire signed [31:0] b_upper;
    assign integration_lower_bound = a_lower;
    assign integration_upper_bound = b_upper;
    
    // Computation signals
    wire start_computation;
    wire signed [31:0] integral_result;
    
    // Keypad interaction signals
    wire [1:0] cursor_row;
    wire [2:0] cursor_col;
    wire keypad_btn_pressed;
    wire [3:0] keypad_selected_value;
    
    // Input builder signals
    wire is_active_mode;
    wire signed [31:0] fp_value;
    wire [31:0] bcd_value;
    wire [3:0] decimal_pos;
    wire has_decimal;
    wire has_negative;
    wire [3:0] input_index;
    
    // Display output wires
    wire [15:0] keypad_oled_data;
    wire [15:0] input_display_oled_data;
    wire [15:0] result_display_oled_data;
    
    // Control module 
    integral_control control(
        .clk(clk_1kHz),
        .reset(reset || !is_integral_mode),
        .btnC(is_integral_mode ? btnC : 1'b0),
        .is_integral_mode(is_integral_mode),
        .input_complete(input_complete),
        .is_computation_complete(is_computation_complete),
        .fp_value(fp_value),
        .computation_result(integral_result),
        .is_integral_input_mode(is_integral_input_mode),
        .is_input_a(is_input_a),
        .is_input_b(is_input_b),
        .a_lower(a_lower),
        .b_upper(b_upper),
        .start_computation(start_computation),
        .is_complete(is_complete),
        .integral_result(integral_result),
        .is_active_mode(is_active_mode)
    );
    
    // Cursor controller
    integral_cursor_controller cursor_ctrl(
        .clk(clk_1kHz),
        .reset(reset || !is_integral_mode),
        .btnC(is_integral_mode ? btnC : 1'b0),
        .btnU(is_integral_mode ? btnU : 1'b0),
        .btnD(is_integral_mode ? btnD : 1'b0),
        .btnL(is_integral_mode ? btnL : 1'b0),
        .btnR(is_integral_mode ? btnR : 1'b0),
        .is_integral_mode(is_integral_mode),
        .is_integral_input_mode(is_integral_input_mode),
        .cursor_row(cursor_row),
        .cursor_col(cursor_col),
        .keypad_btn_pressed(keypad_btn_pressed),
        .keypad_selected_value(keypad_selected_value)
    );
    
    // Input builder
    unified_input_bcd_to_fp_builder input_builder(
        .clk(clk_1kHz),
        .keypad_btn_pressed(keypad_btn_pressed),
        .selected_keypad_value(keypad_selected_value),
        .is_active_mode(is_active_mode && is_integral_mode),
        .reset(reset || !is_integral_mode),
        .enable_negative(1),  // Enable negative input for integral bounds
        .enable_backspace(0), // Disable backspace
        .has_decimal(has_decimal),
        .has_negative(has_negative),
        .input_index(input_index),
        .fp_value(fp_value),
        .bcd_value(bcd_value),
        .input_complete(input_complete),
        .decimal_pos(decimal_pos)
    );
    
    // Computation module
    integral_computation computation(
        .clk(clk_1kHz),
        .reset(reset || !is_integral_mode),
        .start_computation(start_computation),
        .coeff_a(coeff_a),
        .coeff_b(coeff_b),
        .coeff_c(coeff_c),
        .coeff_d(coeff_d),
        .a_lower(a_lower),
        .b_upper(b_upper),
        .integral_result(integral_result),
        .is_computation_complete(is_computation_complete)
    );
    
    // Keypad display (reuse, neat!)
    polynomial_table_keypad_display keypad_disp(
        .clk(clk_6p25MHz),
        .pixel_index(one_pixel_index),
        .cursor_row(cursor_row),
        .cursor_col(cursor_col),
        .oled_data(keypad_oled_data),
        .has_decimal(has_decimal),
        .has_negative(has_negative)
    );
    
    // Input display 
    integral_input_display input_disp(
        .clk(clk_6p25MHz),
        .pixel_index(two_pixel_index),
        .bcd_value(bcd_value),
        .decimal_pos(decimal_pos),
        .input_index(input_index),
        .has_decimal(has_decimal),
        .has_negative(has_negative),
        .is_input_a(is_input_a),
        .is_input_b(is_input_b),
        .oled_data(input_display_oled_data)
    );
    
    // Result display 
    integral_result_display result_disp(
        .clk(clk_6p25MHz),
        .pixel_index(one_pixel_index),
        .integral_result(integral_result),
        .oled_data(result_display_oled_data)
    );
    
    // Output multiplexing for the first OLED
    assign one_oled_data = is_integral_input_mode ? keypad_oled_data : 
                          (is_complete ? result_display_oled_data : 16'hFFFF);
    
    // Output for the second OLED
    assign two_oled_data = is_integral_input_mode ? input_display_oled_data : 16'hFFFF;
endmodule
