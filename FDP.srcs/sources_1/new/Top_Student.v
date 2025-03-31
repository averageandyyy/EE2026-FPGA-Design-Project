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
    
    
    // 25MHz clock for screen display
    wire clk_25MHz;
    flexible_clock_divider clk_25MHz_gen(
        .main_clock(basys_clock),
        .ticks(7),
        .output_clock(clk_25MHz)
    );

    wire graph_active;
    wire [15:0] graph_oled_data; 
    reg zoom_level = 1;
    reg is_graphing_mode = 1'b1;
    
    graph_display graph (
        .led(led),
        .btnU(btnU), 
        .btnD(btnD), 
        .btnL(btnL), 
        .btnR(btnR),
        .btnC(btnC),
        .clk(clk_6p25MHz),
        .pixel_index(one_pixel_index),
        //.zoom_level(3'b001),    // Simple zoom by Danial
        .coeff_1( {{12{1'b0}}, sw[14:12], {16{1'b0}}} ),
        .coeff_2( {{11{1'b0}}, sw[11:8], {16{1'b0}}} ),
        .coeff_3( {{11{1'b0}}, sw[7:4], {16{1'b0}}} ),
        .coeff_4( {{11{1'b0}}, sw[3:0], {16{1'b0}}} ),
        .is_integrate(sw[15]),
        .colour(16'hF800), 
        .is_graphing_mode(is_graphing_mode),
        .oled_data(graph_oled_data), // OLED pixel data (RGB 565 format)
        .oled_valid(graph_active),
        .seg(seg),
        .an(an)
    );

    // Combine the pixel data from all sprites
    assign one_oled_data = graph_active ? graph_oled_data :
                           16'hFFFF; // Background
endmodule