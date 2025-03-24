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
    inout  wire        ps2_clk,     // PS/2 clock line
    inout  wire        ps2_data     // PS/2 data line
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

    // Second OLED display unit (to render outputs)
    wire two_frame_begin;
    wire two_sample_pixel;
    wire [12:0]JA_pixel_index;
    wire two_sending_pixels;
    wire [15:0]JA_oled_data;
    wire [12:0] JA_rotated_pixel_index;

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

    wire [15:0] table_keypad_oled_data;
    wire [15:0] poly_input_oled_data;
    wire [6:0] curr_x, curr_y;
    wire is_table_mode = 1;
    polynomial_table_module poly_table(
        .clk_6p25MHz(clk_6p25MHz),
        .clk_1kHz(clk_1kHz),
        .clk_100MHz(basys_clock),
        .btnC(btnC),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .xpos(curr_x),
        .ypos(curr_y), 
        .use_mouse(sw[0]),
        .mouse_left(left), 
        .mouse_middle(middle),
        .is_table_mode(is_table_mode),
        .coeff_a(32'h00010000), // 1.0
        .coeff_b(32'h00020000), // 2.0
        .coeff_c(32'h00030000), // 3.0
        .coeff_d(32'h00040000), // 4.0
        .one_pixel_index(JB_pixel_index),
        .two_pixel_index(JA_rotated_pixel_index),
        .one_oled_data(table_keypad_oled_data),
        .two_oled_data(poly_input_oled_data)
    );
    wire [15:0] JB_bg_data;
    //cursor overlay on JB screen only
    on_screen_cursor unit_1 (.basys_clock(clk_6p25MHz),.pixel_index(JB_pixel_index),
             .graph_mode_check(1'b1), .value(value),.setx(setx),.sety(sety),.setmax_x(setmax_x),.setmax_y(setmax_y),
             .xpos(xpos), .ypos(ypos),.bg_data(JB_bg_data),.oled_data(JB_oled_data), .cursor_x(curr_x), .cursor_y(curr_y));
    assign left = led[15];
    rotate_180_for_JA rotate180(JA_pixel_index, JA_rotated_pixel_index);
    assign JB_bg_data = is_table_mode ? table_keypad_oled_data : 0;
    assign JA_oled_data = is_table_mode ? poly_input_oled_data : 0; 

endmodule