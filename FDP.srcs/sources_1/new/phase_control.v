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
    input clk_100MHz,
    input clk_6p25MHz,
    input clk_1kHz,
    input [12:0] one_pixel_index,
    input [12:0] two_pixel_index,
    output [15:0] one_oled_data,
    output [15:0] two_oled_data,
    input btnU, btnD, btnC, btnL, btnR,
    input back_switch,
    input [11:0] xpos,
    input [11:0] ypos,
    input pan_zoom_toggle,
    input use_mouse,
    input mouse_left,
    input mouse_middle,
    output [15:0] led,
    output [3:0] an,
    output [7:0] seg
    );

    // Phase state signals
    wire is_phase_two;
    wire is_phase_three;
    wire is_arithmetic_mode;
    wire is_getting_coefficients;
    wire is_integration_mode;
    wire is_plot_mode;

    // OLED data from each phase
    wire [15:0] phase_one_oled_data;
    wire [15:0] phase_two_oled_data;
    wire [15:0] phase_three_one_oled_data;
    wire [15:0] phase_three_two_oled_data;

    wire overflow_flag;
    wire overflow_done;

    // Instantiate phase one wrapper
    phase_one_wrapper phase_one(
        .clk_6p25MHz(clk_6p25MHz),
        .clk_1kHz(clk_1kHz),
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
        .clk_6p25MHz(clk_6p25MHz),
        .clk_1kHz(clk_1kHz),
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

    // Instantiate phase three wrapper
    phase_three_wrapper phase_three(
        .clk_100MHz(clk_100MHz),
        .clk_1kHz(clk_1kHz),
        .clk_6p25MHz(clk_6p25MHz),
        .one_pixel_index(one_pixel_index),
        .two_pixel_index(two_pixel_index),
        .one_oled_data(phase_three_one_oled_data),
        .two_oled_data(phase_three_two_oled_data),
        .btnU(btnU),
        .btnD(btnD),
        .btnC(btnC),
        .btnL(btnL),
        .btnR(btnR),
        .is_phase_three(is_phase_three),
        .pan_zoom_toggle(pan_zoom_toggle),
        .is_arithmetic_mode(is_arithmetic_mode),
        .is_getting_coefficients(is_getting_coefficients),
        .back_switch(back_switch),
        .xpos(xpos),
        .ypos(ypos),
        .use_mouse(use_mouse),
        .mouse_left(mouse_left),
        .overflow_flag(overflow_flag),
        .integration_mode(is_integration_mode),
        .plot_mode(is_plot_mode)
    );

    // Output selection based on active phase
    assign one_oled_data = is_phase_three ? phase_three_one_oled_data :
                          (is_phase_two ? phase_two_oled_data : phase_one_oled_data);
                          
    assign two_oled_data = is_phase_three ? phase_three_two_oled_data : 16'h0000;
    
    assign seven_segment_mode = is_phase_three ? 
    (is_arithmetic_mode ? 4'b0001 : (is_integration_mode ? 4'b0011 : (is_plot_mode ? 4'b0100 : 4'b0010)))
    : (use_mouse ? 4'b1111 : 4'b0000);

    // Controlling the seven segment display
    seven_seg_controller ssc(
        .seg(seg),
        .an(an),
        .back_switch(back_switch),
        .my_1_khz_clk(clk_1kHz),
        .seven_segment_mode(seven_segment_mode),
        .overflow_flag(overflow_flag)
    );

    // Debug LEDs
    assign led[0] = is_phase_two;
    assign led[1] = is_phase_three;
    assign led[2] = is_arithmetic_mode;
    assign led[3] = is_getting_coefficients;
endmodule
