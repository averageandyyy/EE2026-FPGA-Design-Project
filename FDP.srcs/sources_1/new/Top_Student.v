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
      assign rst = sw[0];
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
     //part that tracks the number of scroll wheel inputs
    wire [3:0] scroll_leds;
         scroll_led_accum scroll_test (
              .clk         (basys_clock),
              .rst         (rst),
              .new_event   (new_event),
              .zpos        (zpos),
              .scroll_dir (scroll_leds));
   //end of part that tracks the number of scroll wheel inputs, shift this around if needed
  
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
    wire [15:0] JB_bg_data;
    phase_control phase(
        .clk_100MHz(basys_clock),
        .clk_1kHz(clk_1kHz),
        .clk_6p25MHz(clk_6p25MHz),
        .one_pixel_index(JB_pixel_index),
        .two_pixel_index(JA_pixel_index),
        .one_oled_data(JB_bg_data),
        .two_oled_data(JA_oled_data),
        .btnU(btnU),
        .btnD(btnD),
        .btnC(btnC),
        .btnL(btnL),
        .btnR(btnR),
        .back_switch(sw[15]),
        .rst(rst),
        .led(led),
        .an(an),
        .seg(seg),
        .xpos(xpos),
        .ypos(ypos),
        .use_mouse(1),
        .mouse_left(left),
        .mouse_middle(middle),
        .mouse_right(right),
        .zpos(zpos) //here, scroll_leds starts at 0, then if we scroll up is 0001,
        //then 0011, 0111, 1111, scroll back down is 1111, 0111, 0011, 0001, 0000
    );
    wire [6:0] curr_x, curr_y;
    on_screen_cursor unit_1 (.basys_clock(clk_6p25MHz),
             .pixel_index(JB_pixel_index),
             .graph_mode_check(1), //change this if ncessary, when to use the mouse and wben not to use the mouse
             .value(value),.setx(setx),
             .sety(sety),
             .setmax_x(setmax_x),.setmax_y(setmax_y),
             .xpos(xpos), .ypos(ypos),.bg_data(JB_bg_data),
             .oled_data(JB_oled_data), 
             .cursor_x(curr_x), .cursor_y(curr_y));
    //curr_x and curr_y is an output that stores the value of the current cursor position in the screen

endmodule
