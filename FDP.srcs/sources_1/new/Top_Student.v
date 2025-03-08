`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: Cheng Jia Wei Andy
//  STUDENT B NAME: Wayne
//  STUDENT C NAME: Wei Hao
//  STUDENT D NAME: Daniel
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
    input basys_clock, 
    input btnC, 
    input btnU, 
    input btnD,
    input btnL,
    input btnR, 
    output [7:0]JB,
    input [15:0]sw,
    output [15:0]led,
    output [3:0]an,
    output [7:0]seg
    );

    // Initialize clock for OLED display
    wire clk6p25m;
    flexible_clock_divider clk_6p25m(.main_clock(basys_clock), .ticks(7), .output_clock(clk6p25m));
    
    // Initialize wires for OLED display
    wire frame_begin;
    wire sample_pixel;
    wire [12:0]pixel_index;
    wire sending_pixels;
    wire [15:0] oled_data;

    // These wires can be considered 'global' variables that are to be shared amongst subtasks, since all modules will communicate
    // with only 1 display
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
    
    wire [15:0]collision_oled;
    collision_module collision(
        .basys_clock(basys_clock),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .pixel_index(pixel_index),
        .oled_data(collision_oled)
    );

    
    
    wire [15:0]team_oled_data;
    team_oled team(
        .pixel_index(pixel_index),
        .oled_data(team_oled_data)
    );
    
    
    
    // Task A variables, 9 = rightmost, blink at 10Hz aka no blink
    // switches 0 1 2 4 8 9 and 12 form the password
    parameter [15:0]APassword = 16'b0001_0011_0001_0111;
    wire hasAPassword;
    assign hasAPassword = (sw == APassword);
    wire clk_10Hz;
    flexible_clock_divider clk_10Hz_gen(.main_clock(basys_clock), .ticks(4999999), .output_clock(clk_10Hz));
    wire [15:0]ALights;
    get_blinking_lights(.input_clock(clk_10Hz), .leds(ALights), .password(APassword), .exclude(12));
    wire [15:0]circle_oled;
    circle_module circle(
    .basys_clock(basys_clock),
    .pixel_index(pixel_index),
    .oled_data(circle_oled),
    .btnC(btnC),
    .btnU(btnU),
    .btnD(btnD),
    .hasPassword(hasAPassword)
    );
    
    assign led = hasAPassword ? ALights : sw;
    
    // Logic for integration to control which subtask to render
    // wire isCircle = 1;
    assign oled_data = hasAPassword ? circle_oled : team_oled_data;
endmodule