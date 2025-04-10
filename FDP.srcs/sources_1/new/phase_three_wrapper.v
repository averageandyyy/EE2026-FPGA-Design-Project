`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 13:32:58
// Design Name: 
// Module Name: phase_three_wrapper
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
In phase_two, we have the option of choosing between arithmetic and function. When the user chooses arithmetic, we would set is_phase_three to true and is_arithmetic_mode to true. At this point, we can let control to be taken over by the arithmetic_module and its displays to be rendered.

Should the user choose function, that's when things get more complicated. First of we should enter a GET_COEFFICIENTS state where the user will be providing input a total of 4 times, inputting the 4 different coefficients. We can reuse the unified_input_builder and also the polynomial_keypad_display at this stage. Perhaps 4 states corresponding to the 4 inputs will be good. Afterward gathering all inputs, we transition to a MENU_SELECTION state. At this point, another menu controller with 2 rows  takes over a and a menu display with 2 buttons are rendered. The user can choose between TABLE and INTG, which are the 2 rendered buttons. On the second OLED screen we can render the graph with graph_display_cached.  On selection of a function, we transition over to a SELECTED_FUNCTION state, where control and renders are handed over to the module of interest. For table it would be polynomial_table_module and for integration (math) it will be.

The forward transitions look like this:
GET_COEFFICIENTS(A to D) -> MENU_SELECTION -> SELECTED_FUNCTION

The user should be able to traverse backwards via our current backing sequence of having the back_switch on and pressing btnL. From MENU_SELECTION, the backwards traversal should go to the very first coefficient getting. 

Also notice how under phase_two_controller, we disable is_phase_three only if the user is in arithmetic mode or is_getting_coefficients, meaning if the program is at one of the GET_COEFFICIENTS state, it must be communicated back.
*/
module phase_three_wrapper(
    input clk_100MHz,
    input clk_1kHz,
    input clk_6p25MHz,
    input rst,
    input [12:0] one_pixel_index,
    input [12:0] two_pixel_index,
    output [15:0] one_oled_data,
    output [15:0] two_oled_data,
    input btnU, btnD, btnC, btnL, btnR,
    input is_phase_three,
    input is_arithmetic_mode,
    output is_getting_coefficients,
    input back_switch,
    input [11:0] xpos,
    input [11:0] ypos,
    input [3:0] zpos,
    input use_mouse,
    input mouse_left,
    input mouse_middle,
    input new_event
    );

    // State signals from controller
    wire is_menu_selection;
    wire is_table_selected;
    wire is_integral_selected;
    wire [1:0] coeff_state;
    wire cursor_row;

    // Coefficient values
    wire signed [31:0] coeff_a, coeff_b, coeff_c, coeff_d;

    // Keypad and input signals
    wire keypad_active;
    wire input_complete;
    wire signed [31:0] fp_value;

    // Unified input builder signals
    wire has_decimal;
    wire has_negative;
    wire [3:0] input_index;
    wire [31:0] bcd_value;
    wire [3:0] decimal_pos;

    // Cursor signals (for when we get coefficients)
    wire [1:0] keypad_cursor_row;
    wire [2:0] keypad_cursor_col;
    wire keypad_btn_pressed;
    wire [3:0] keypad_selected_value;

    // Module output wires, will MUX amongst all of these
    wire [15:0] keypad_oled_data;
    wire [15:0] coeff_display_oled_data;
    wire [15:0] menu_oled_data;
    wire [15:0] table_one_oled_data;
    wire [15:0] integral_one_oled_data;
    wire [15:0] table_two_oled_data;
    wire [15:0] integral_two_oled_data;
    wire [15:0] graph_oled_data;
    wire [15:0] arithmetic_one_oled_data;
    wire [15:0] arithmetic_two_oled_data;

    // Controllers and modules
    phase_three_controller controller(
        .clock(clk_1kHz),
        .btnU(btnU),
        .btnD(btnD),
        .btnC(btnC),
        .btnL(btnL),
        .btnR(btnR),
        .back_switch(back_switch),
        .is_phase_three(is_phase_three),
        .is_arithmetic_mode(is_arithmetic_mode),
        .is_getting_coefficients(is_getting_coefficients),
        .coeff_state(coeff_state),
        .is_menu_selection(is_menu_selection),
        .is_table_selected(is_table_selected),
        .is_integral_selected(is_integral_selected),
        .cursor_row(cursor_row),
        .coeff_a(coeff_a),
        .coeff_b(coeff_b),
        .coeff_c(coeff_c),
        .coeff_d(coeff_d),
        .input_complete(input_complete),
        .fp_value(fp_value),
        .keypad_active(keypad_active)
    );

    // Unified input builder for coefficients
    unified_input_bcd_to_fp_builder input_builder(
        .clk(clk_1kHz),
        .keypad_btn_pressed(keypad_btn_pressed),
        .selected_keypad_value(keypad_selected_value),
        .is_active_mode(keypad_active && is_phase_three && !is_arithmetic_mode),
        .reset(!is_phase_three || !keypad_active),
        .enable_negative(1),
        .enable_backspace(0),
        .has_decimal(has_decimal),
        .has_negative(has_negative),
        .input_index(input_index),
        .fp_value(fp_value),
        .bcd_value(bcd_value),
        .input_complete(input_complete),
        .decimal_pos(decimal_pos)
    );

    // Coefficient input cursor controller (reused from integral), interfaces with the input builder
    integral_cursor_controller coeff_cursor_ctrl(
        .clk(clk_1kHz),
        .clk_6p25MHz(clk_6p25MHz),
        .clk_100MHz(clk_100MHz),
        .xpos(xpos),
        .ypos(ypos),
        .mouse_left(mouse_left),
        .reset(!is_getting_coefficients || !is_phase_three),
        .btnC((is_getting_coefficients && keypad_active) ? btnC : 1'b0),
        .btnU((is_getting_coefficients && keypad_active) ? btnU : 1'b0),
        .btnD((is_getting_coefficients && keypad_active) ? btnD : 1'b0),
        .btnL((is_getting_coefficients && keypad_active) ? btnL : 1'b0),
        .btnR(is_getting_coefficients ? btnR : 1'b0),
        .is_integral_mode(is_getting_coefficients && is_phase_three && keypad_active),
        .is_integral_input_mode(is_getting_coefficients && is_phase_three && keypad_active),
        .cursor_row(keypad_cursor_row),
        .cursor_col(keypad_cursor_col),
        .keypad_btn_pressed(keypad_btn_pressed),
        .keypad_selected_value(keypad_selected_value)
    );

    // Keypad display for coefficients (Reuse! since it has negative sign)
    polynomial_table_keypad_display keypad_display(
        .clk(clk_6p25MHz),
        .pixel_index(one_pixel_index),
        .cursor_row(keypad_cursor_row),
        .cursor_col(keypad_cursor_col),
        .has_decimal(has_decimal),
        .has_negative(has_negative),
        .input_index(input_index),
        .oled_data(keypad_oled_data)
    );

    // Coefficient input display (modified from integral_input_display, with more input labels)
    coefficient_input_display coeff_input_display(
        .clk(clk_6p25MHz),
        .pixel_index(two_pixel_index),
        .bcd_value(bcd_value),
        .decimal_pos(decimal_pos),
        .input_index(input_index),
        .has_decimal(has_decimal),
        .has_negative(has_negative),
        .coeff_state(coeff_state),
        .oled_data(coeff_display_oled_data)
    );

    // Phase three menu display (choosing between TABLE AND INTG)
    phase_three_menu_display menu_display(
        .clock(clk_6p25MHz),
        .pixel_index(one_pixel_index),
        .cursor_row(cursor_row),
        .btnC(btnC),
        .oled_data(menu_oled_data)
    );

    // Graph display for showing function
    graph_display_cached graph_display(
        .clk(clk_6p25MHz),
        .clk_100MHz(clk_100MHz),
        // I disabled the buttons for now to make sure it doesnt intefere with other stuff
        .btnU(0),
        .btnD(0),
        .btnL(0),
        .btnR(0),
        .btnC(0),
        .rst(rst),
        .pixel_index(two_pixel_index),
        .coeff_a(coeff_a),
        .coeff_b(coeff_b),
        .coeff_c(coeff_c),
        .coeff_d(coeff_d),
        .curr_x(xpos),
        .curr_y(ypos),
        .zoom_level(4'h5), // Default zoom level
        .zpos(zpos),
        .mouse_left(mouse_left),
        .mouse_right(1'b0),
        .mouse_middle(mouse_middle),
        .new_event(new_event),
        .colour(16'hF800), // Red line for graph
        .is_graphing_mode(is_menu_selection || is_table_selected || is_integral_selected),
        .is_integrate(is_integral_selected),
        .integration_lower_bound(32'hFFFFE000), // Default -2.0
        .integration_upper_bound(32'h00002000), // Default 2.0
        .oled_data(graph_oled_data)
    );

    // Polynomial table module
    polynomial_table_module table_module(
        .clk_6p25MHz(clk_6p25MHz),
        .clk_1kHz(clk_1kHz),
        .clk_100MHz(clk_100MHz), 
        .btnC(btnC),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .xpos(xpos),
        .ypos(ypos),
        .use_mouse(use_mouse),
        .mouse_left(mouse_left),
        .mouse_middle(mouse_middle),
        .is_table_mode(is_table_selected),
        .coeff_a(coeff_a),
        .coeff_b(coeff_b),
        .coeff_c(coeff_c),
        .coeff_d(coeff_d),
        .one_pixel_index(one_pixel_index),
        .two_pixel_index(two_pixel_index),
        .one_oled_data(table_one_oled_data),
        .two_oled_data(table_two_oled_data),
        .new_event(new_event),
        .rst(rst),
        .zpos(zpos)
    );

    // Integral module
    integral_module integral_module(
        .clk_6p25MHz(clk_6p25MHz),
        .clk_1kHz(clk_1kHz),
        .clk_100MHz(clk_100MHz),
        .xpos(xpos),
        .ypos(ypos),
        .mouse_left(mouse_left),
        .btnC(btnC),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .reset(!is_integral_selected),
        .is_integral_mode(is_integral_selected),
        .coeff_a(coeff_a),
        .coeff_b(coeff_b),
        .coeff_c(coeff_c),
        .coeff_d(coeff_d),
        .one_pixel_index(one_pixel_index),
        .two_pixel_index(two_pixel_index),
        .one_oled_data(integral_one_oled_data),
        .two_oled_data(integral_two_oled_data)
    );

    // Arithmetic module (the simplest module lol)
    arithmetic_module arithmetic_module(
        .clk_6p25MHz(clk_6p25MHz),
        .clk_100MHz(clk_100MHz),
        .clk_1kHz(clk_1kHz),
        .btnC(btnC),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .reset(!is_arithmetic_mode),
        .is_arithmetic_mode(is_arithmetic_mode),
        .xpos(xpos),
        .ypos(ypos),
        .use_mouse(use_mouse),
        .mouse_left(mouse_left),
        .mouse_middle(mouse_middle),
        .one_pixel_index(one_pixel_index),
        .two_pixel_index(two_pixel_index),
        .one_oled_data(arithmetic_one_oled_data),
        .two_oled_data(arithmetic_two_oled_data)
    );

    // Output multiplexing for the first OLED
    assign one_oled_data = 
        (is_phase_three && is_arithmetic_mode) ? arithmetic_one_oled_data :
        (is_getting_coefficients) ? keypad_oled_data :
        (is_menu_selection) ? menu_oled_data :
        (is_table_selected) ? table_one_oled_data :
        (is_integral_selected) ? integral_one_oled_data :
        16'h0000;

    // Output multiplexing for the second OLED
    assign two_oled_data = 
        (is_phase_three && is_arithmetic_mode) ? arithmetic_two_oled_data :
        (is_getting_coefficients) ? coeff_display_oled_data :
        (is_menu_selection) ? graph_oled_data :
        (is_table_selected) ? table_two_oled_data :
        (is_integral_selected) ? integral_two_oled_data :
        16'h0000;
endmodule
