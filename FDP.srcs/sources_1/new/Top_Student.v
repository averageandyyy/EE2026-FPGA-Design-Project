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
    output [6:0]seg, // 7-segment display
    output [3:0]an
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

    // Connect arithmetic keypad renderer to first OLED
//    arithmetic_keypad_renderer keypad_renderer(
//        .clk(clk_6p25MHz),
//        .pixel_index(one_pixel_index),
//        .cursor_row_keypad(cursor_row_keypad),
//        .cursor_col_keypad(cursor_col_keypad),
//        .cursor_row_operand(cursor_row_operand),
//        .cursor_col_operand(cursor_col_operand),
//        .has_decimal(has_decimal),
//        .is_operand_mode(is_operand_mode),
//        .oled_data(one_oled_data)
//    );

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
    
//    // Second OLED display unit (to render outputs)
//    wire two_frame_begin;
//    wire two_sample_pixel;
//    wire [12:0]two_pixel_index;
//    wire two_sending_pixels;
//    wire [15:0]two_oled_data;

//    // Connect result renderer to second OLED
//    arithmetic_result_renderer result_renderer(
//        .clk(clk_6p25MHz),
//        .pixel_index(two_pixel_index),
//        .result(result),
//        .is_operand_mode(is_operand_mode),
//        .oled_data(two_oled_data)
//    );

//    Oled_Display second_display(
//        .clk(clk_6p25MHz),
//        .reset(0),
//        .frame_begin(two_frame_begin),
//        .sending_pixels(two_sending_pixels),
//        .sample_pixel(two_sample_pixel),
//        .pixel_index(two_pixel_index),
//        .pixel_data(two_oled_data),
//        .cs(JA[0]), 
//        .sdin(JA[1]), 
//        .sclk(JA[3]), 
//        .d_cn(JA[4]), 
//        .resn(JA[5]), 
//        .vccen(JA[6]),
//        .pmoden(JA[7])
//    );
    
    main_menu mm(btnC, btnU, btnD, btnL, btnR, basys_clock, one_pixel_index, seg, one_oled_data, an);

endmodule