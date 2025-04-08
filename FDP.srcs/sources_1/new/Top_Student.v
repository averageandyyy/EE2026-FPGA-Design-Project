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
    //mouse part
    // Default input values for the mouse_module
    wire [11:0] value;
    assign value = 12'b0; // Default value is 0 (origin)
            
    wire setx;
    assign setx = 1'b0;   // No update command, keep current position
            
    wire sety;
    assign sety = 1'b0;   // No update command, keep current position
            
    wire setmax_x;
    assign setmax_x= 1'b0; // Do not update max_x
            
    wire setmax_y;
    assign setmax_y = 1'b0; // Do not update max_y
    wire [11:0] xpos;
    wire [11:0] ypos;
    wire [3:0]  zpos;
    wire        left;
    wire        middle;
    wire        right;
    wire        new_event;
    wire        rst;        // Reset signal
    mouse_module unit_0 (
        .clk       (basys_clock),
        .rst       (rst),
        .value     (value),
        .setmax_x  (setmax_x),
        .setmax_y  (setmax_y),
        .setx      (setx),
        .sety      (sety),
        .ps2_clk   (ps2_clk),
        .ps2_data  (ps2_data),
        .xpos      (xpos),
        .ypos      (ypos),
        .zpos      (zpos),
        .left      (left),
        .middle    (middle),
        .right     (right),
        .new_event (new_event)
    );
    //end of mouse part

    
    // First OLED display unit (for user input)
    wire one_frame_begin;
    wire one_sample_pixel;
    wire [12:0]JB_pixel_index;
    wire one_sending_pixels;
    wire [15:0]JB_oled_data;

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
    
    wire graph_active;
    // 25MHz clock for screen display
    wire clk_25MHz;
    flexible_clock_divider clk_25MHz_gen(
        .main_clock(basys_clock),
        .ticks(7),
        .output_clock(clk_25MHz)
    );
    wire [6:0] curr_x, curr_y;
    wire [15:0] JB_bg_data;
    
    wire [15:0] graph_oled_data; 
    reg zoom_level = 1;
    reg is_graphing_mode = 1'b1;
    
    wire clk_50MHz;
    flexible_clock_divider clk_50MHz_gen(
        .main_clock(basys_clock),
        .ticks(0),
        .output_clock(clk_50MHz)
    );

    graph_display_cached graph (
        .clk(basys_clock),
        .btnU(btnU), .btnD(btnD), .btnL(btnL), .btnR(btnR), .btnC(btnC),
        .pixel_index(JB_pixel_index),
        .coeff_a( {{12{1'b0}}, sw[14:12], {16{1'b0}}} ),
        .coeff_b( {{11{1'b0}}, sw[11:8], {16{1'b0}}} ),
        .coeff_c( {{11{1'b0}}, sw[7:4], {16{1'b0}}} ),
        .coeff_d( {{11{1'b0}}, sw[3:0], {16{1'b0}}} ),
        .curr_x(xpos),
        .curr_y(ypos),
        .zoom_level(zpos),
        .mouse_left(left),
        .new_event(new_event),
        .mouse_middle(middle),
        .mouse_right(right),
        .colour(16'hF800),
        .is_graphing_mode(is_graphing_mode),
        .is_integrate(sw[15]),
        .oled_data(graph_oled_data), // OLED pixel data (RGB 565 format)
        .integration_lower_bound(0),
        .integration_upper_bound(0)
    );

    on_screen_cursor unit_1 (.basys_clock(clk_6p25MHz),
        .pixel_index(JB_pixel_index),
        .graph_mode_check(1), 
        .value(value),.setx(setx),
        .sety(sety),
        .setmax_x(setmax_x),.setmax_y(setmax_y),
        .xpos(xpos), .ypos(ypos),.bg_data(JB_bg_data),
        .oled_data(JB_oled_data), 
        .cursor_x(curr_x), .cursor_y(curr_y));

    // Combine the pixel data from all sprites
    assign JB_bg_data = 1 ? graph_oled_data :
                           16'hFFFF; // Background
endmodule