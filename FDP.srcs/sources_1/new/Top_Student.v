`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
    input basys_clock, 
    input [15:0] sw, 
    output [15:0] led,
    input btnC, btnU, btnD, btnL, btnR,
    output [7:0]JB, // First OLED
    output [7:0]JA,  // Second OLED
    inout wire ps2_clk,
    inout wire ps2_data,
    output [7:0] seg,
    output [3:0] an
    );

    // 6.25MHz clock for OLED displays
    wire clk_6p25MHz;
    flexible_clock_divider clk_6p25MHz_gen(
        .main_clock(basys_clock),
        .ticks(7),
        .output_clock(clk_6p25MHz)
    ); 

    // 1kHz clock for cursor_controller
    wire clk_1kHz;
    flexible_clock_divider clk_1kHz_gen(
        .main_clock(basys_clock),
        .ticks(49999),
        .output_clock(clk_1kHz)
    );

    // First OLED display unit (for user input)
    wire one_frame_begin;
    wire one_sample_pixel;
    wire [12:0]JB_pixel_index;
    wire one_sending_pixels;
    wire [15:0]JB_oled_data;

    // Second OLED display unit
    wire two_frame_begin;
    wire two_sample_pixel;
    wire [12:0]JA_pixel_index;
    wire two_sending_pixels;
    wire [15:0]JA_oled_data;

    Oled_Display first_display(
        .clk(clk_6p25MHz),
        .reset(0),
        .frame_begin(one_frame_begin),
        .sending_pixels(one_sending_pixels),
        .sample_pixel(one_sample_pixel),
        .pixel_index(JB_pixel_index),
        .pixel_data(JB_oled_data),
        .cs(JB[0]), 
        .sdin(JB[1]), 
        .sclk(JB[3]), 
        .d_cn(JB[4]), 
        .resn(JB[5]), 
        .vccen(JB[6]),
        .pmoden(JB[7])
    );

    Oled_Display second_display(
        .clk(clk_6p25MHz),
        .reset(0),
        .frame_begin(two_frame_begin),
        .sending_pixels(two_sending_pixels),
        .sample_pixel(two_sample_pixel),
        .pixel_index(JA_pixel_index),
        .pixel_data(JA_oled_data),
        .cs(JA[0]), 
        .sdin(JA[1]), 
        .sclk(JA[3]), 
        .d_cn(JA[4]), 
        .resn(JA[5]), 
        .vccen(JA[6]),
        .pmoden(JA[7])
    );

    phase_control phase(
        .clk_100MHz(basys_clock),
        .clk_1kHz(clk_1kHz),
        .clk_6p25MHz(clk_6p25MHz),
        .one_pixel_index(JB_pixel_index),
        .two_pixel_index(JA_pixel_index),
        .one_oled_data(JB_oled_data),
        .two_oled_data(JA_oled_data),
        .btnU(btnU),
        .btnD(btnD),
        .btnC(btnC),
        .btnL(btnL),
        .btnR(btnR),
        .back_switch(sw[15]),
        .led(led),
        .an(an),
        .seg(seg)
    );

endmodule
