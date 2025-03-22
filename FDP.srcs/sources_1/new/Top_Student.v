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
    output [7:0]JA  // Second OLED
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
    wire [12:0]one_pixel_index;
    wire one_sending_pixels;
    wire [15:0]one_oled_data;

    Oled_Display first_display(
        .clk(clk_6p25MHz),
        .reset(0),
        .frame_begin(one_frame_begin),
        .sending_pixels(one_sending_pixels),
        .sample_pixel(one_sample_pixel),
        .pixel_index(one_pixel_index),
        .pixel_data(one_oled_data),
        .cs(JB[0]), 
        .sdin(JB[1]), 
        .sclk(JB[3]), 
        .d_cn(JB[4]), 
        .resn(JB[5]), 
        .vccen(JB[6]),
        .pmoden(JB[7])
    );

    // Second OLED display unit (to render outputs)
    wire two_frame_begin;
    wire two_sample_pixel;
    wire [12:0]two_pixel_index;
    wire two_sending_pixels;
    wire [15:0]two_oled_data;

    Oled_Display second_display(
        .clk(clk_6p25MHz),
        .reset(0),
        .frame_begin(two_frame_begin),
        .sending_pixels(two_sending_pixels),
        .sample_pixel(two_sample_pixel),
        .pixel_index(two_pixel_index),
        .pixel_data(two_oled_data),
        .cs(JA[0]), 
        .sdin(JA[1]), 
        .sclk(JA[3]), 
        .d_cn(JA[4]), 
        .resn(JA[5]), 
        .vccen(JA[6]),
        .pmoden(JA[7])
    );

    wire [15:0] table_keypad_oled_data;
    wire [15:0] poly_input_oled_data;
    wire is_table_mode = 1;
    polynomial_table_module poly_table(
        .clk_6p25MHz(clk_6p25MHz),
        .clk_1kHz(clk_1kHz),
        .btnC(btnC),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .is_table_mode(is_table_mode),
        .coeff_a(32'h00010000), // 1.0
        .coeff_b(32'h00020000), // 2.0
        .coeff_c(32'h00030000), // 3.0
        .coeff_d(32'h00040000), // 4.0
        .one_pixel_index(one_pixel_index),
        .two_pixel_index(two_pixel_index),
        .one_oled_data(table_keypad_oled_data),
        .two_oled_data(poly_input_oled_data)
    );

    assign one_oled_data = is_table_mode ? table_keypad_oled_data : 0;
    assign two_oled_data = is_table_mode ? poly_input_oled_data : 0; 

endmodule