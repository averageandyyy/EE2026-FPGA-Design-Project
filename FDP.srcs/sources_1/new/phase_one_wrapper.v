`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 10:21:26
// Design Name: 
// Module Name: phase_one_wrapper
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


module phase_one_wrapper(
    input clk_100MHz,
    input clk_6p25MHz,
    input clk_1kHz,
    input [12:0] pixel_index,
    output [15:0] oled_data,
    input btnU, btnD, btnC, btnL,
    output is_phase_two,
    input is_phase_three,
    input back_switch,
    input [11:0] xpos, ypos,
    input use_mouse,
    input mouse_left,
    input middle
    );
    
    // Internal connection between controller and display
    wire cursor_row;
    
    // Instantiate controller
    phase_one_menu_controller controller(
        .clock(clk_1kHz),
        .clk_100MHz(clk_100MHz),
        .clk_6p25MHz(clk_6p25MHz),
        .btnU(btnU),
        .btnD(btnD),
        .btnC(btnC),
        .btnL(btnL),
        .cursor_row(cursor_row),
        .is_phase_two(is_phase_two),
        .is_phase_three(is_phase_three),
        .back_switch(back_switch),
        .xpos(xpos),
        .ypos(ypos),
        .use_mouse(use_mouse),
        .mouse_left(mouse_left),
        .middle(middle)
    );
    
    // Instantiate display
    phase_one_menu_display display(
        .clock(clk_6p25MHz),
        .pixel_index(pixel_index),
        .oled_data(oled_data),
        .cursor_row(cursor_row),
        .btnC(btnC), 
        .xpos(xpos),
        .ypos(ypos),
        .clk_100MHz(clk_100MHz),
        .use_mouse(use_mouse),
        .mouse_left(mouse_left),
        .middle(middle)
    );
    
endmodule
