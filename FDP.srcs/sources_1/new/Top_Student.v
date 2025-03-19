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
    input btnC, 
    input btnU, 
    input btnD,
    input btnL,
    input btnR, 
    inout ps2_clk,
    inout ps2_data,
    output [7:0]JB,
    input [15:0]sw,
    output [15:0]led,
    output [3:0]an,
    output [7:0]seg
   );
    
    //Initialize mouse
    wire rst, setmax_x, setmax_y, setx, sety;
    assign setmax_x = 0;
    assign setmax_y = 0;
    assign setx = 0;
    assign sety = 0;
    wire [11:0] xpos, ypos, value;
    assign value = 0;
    wire [3:0] zpos;
    assign zpos = 0;
    wire left, right, middle, new_event;
    mouse_module unit_0 (basys_clock, rst, value, setmax_x, setmax_y, 
    setx, sety, ps2_clk, ps2_data,
    xpos, ypos, zpos, left, middle, right, new_event);

    // Initialize clock for OLED display
    wire clk6p25m;
    flexible_clock_divider clk_6p25m(.main_clock(basys_clock), .ticks(7), .output_clock(clk6p25m));
    
    // Initialize wires for OLED display
    wire frame_begin;
    wire sample_pixel;
    wire [12:0]pixel_index;
    wire sending_pixels;
    wire [15:0] oled_data;
    Oled_Display display(.clk(clk6p25m), 
        .reset(0), 
        .frame_begin(frame_begin), 
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel), 
        .pixel_index(pixel_index), 
        .pixel_data(oled_data), 
        .cs(JB[0]), 
        .sdin(JB[1]), 
        .sclk(JB[3]), 
        .d_cn(JB[4]), 
        .resn(JB[5]), 
        .vccen(JB[6]),
        .pmoden(JB[7]));
    
   
//    assign oled_data = 16'b00000_000000_11111; //just testing, remove later
//    current_onscreen_color bg_inst (.pixel_index(pixel_index), .bg_color(bg_data));
    //change 1 if required to see if the graph if on screen or not, then disable the cursor. i not too sure what
    //is the plan yet
    wire [15:0] bg_data;
    wire [2:0] zoom_mode;
    wire [12:0] scaled_pixel_index;
    on_screen_cursor unit_1 (.basys_clock(clk6p25m),.pixel_index(pixel_index),
        .graph_mode_check(1'b1), .value(value),.setx(setx),.sety(sety),.setmax_x(setmax_x),.setmax_y(setmax_y),
        .xpos(xpos), .ypos(ypos),.bg_data(bg_data),.oled_data(oled_data));
    zoom_button unit_2 (basys_clock, btnU, btnD, btnC, 1, led, zoom_mode);
    zoom_scaler unit_3 (basys_clock, pixel_index, zoom_mode, scaled_pixel_index, 1);
    test_picture bg_rom (.pixel_index(scaled_pixel_index), .pixel_color(bg_data));


endmodule