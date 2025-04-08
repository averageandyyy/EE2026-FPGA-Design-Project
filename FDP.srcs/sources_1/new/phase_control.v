`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 10:21:13
// Design Name: 
// Module Name: phase_control
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


module phase_control(
    input main_clock,
    input [12:0] one_pixel_index,
    input [12:0] two_pixel_index,
    output [15:0] one_oled_data,
    output [15:0] two_oled_data,
    input btnU, btnD, btnC, btnL,
    input back_switch,
    output [15:0] led
    );

    // Phase state signals
    wire is_phase_two;
    wire is_phase_three;
    wire is_arithmetic_mode;

    // OLED data from each phase
    wire [15:0] phase_one_oled_data;
    wire [15:0] phase_two_oled_data;

    // Instantiate phase one wrapper
    phase_one_wrapper phase_one(
        .clock(main_clock),
        .pixel_index(one_pixel_index),
        .oled_data(phase_one_oled_data),
        .btnU(btnU),
        .btnD(btnD),
        .btnC(btnC),
        .btnL(btnL),
        .is_phase_two(is_phase_two),
        .is_phase_three(is_phase_three),
        .back_switch(back_switch)
    );

    // Instantiate phase two wrapper
    phase_two_wrapper phase_two(
        .clock(main_clock),
        .pixel_index(one_pixel_index),
        .oled_data(phase_two_oled_data),
        .btnU(btnU),
        .btnD(btnD),
        .btnC(btnC),
        .btnL(btnL),
        .is_phase_two(is_phase_two),
        .is_phase_three(is_phase_three),
        .is_arithmetic_mode(is_arithmetic_mode),
        .is_getting_coefficients(is_getting_coefficients),
        .back_switch(back_switch)
    );

    assign one_oled_data = is_phase_two ? phase_two_oled_data : phase_one_oled_data;
    assign two_oled_data = 0;

    assign led[0] = is_phase_two;
    assign led[1] = is_phase_three;
endmodule
