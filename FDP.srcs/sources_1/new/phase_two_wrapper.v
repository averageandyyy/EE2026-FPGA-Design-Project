`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 10:21:38
// Design Name: 
// Module Name: phase_two_wrapper
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


module phase_two_wrapper(
    input clk_6p25MHz,
    input clk_1kHz,
    input [12:0] pixel_index,
    output [15:0] oled_data,
    input btnU, btnD, btnC, btnL,
    input is_phase_two,
    output is_phase_three,
    output is_arithmetic_mode,
    input is_getting_coefficients,
    input back_switch
    );
    
    // Internal connection between controller and display
    wire cursor_row;
    
    // Instantiate controller
    phase_two_menu_controller controller(
        .clock(clk_1kHz),
        .btnU(btnU),
        .btnD(btnD),
        .btnC(btnC),
        .btnL(btnL),
        .cursor_row(cursor_row),
        .is_phase_three(is_phase_three),
        .is_arithmetic_mode(is_arithmetic_mode),
        .is_getting_coefficients(is_getting_coefficients),
        .is_phase_two(is_phase_two),
        .back_switch(back_switch)
    );
    
    // Instantiate display
    phase_two_menu_display display(
        .clock(clk_6p25MHz),
        .pixel_index(pixel_index),
        .oled_data(oled_data),
        .cursor_row(cursor_row),
        .btnC(btnC)
    );
    
endmodule
