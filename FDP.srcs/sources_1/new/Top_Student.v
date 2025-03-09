`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: Cheng Jia Wei Andy
//  STUDENT B NAME: Wayne
//  STUDENT C NAME: Ho Wei Hao
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
    
    // Task B variables, 3 = rightmost, blink at 4Hz.
    // Switches 0, 1, 2, 3, 8 and 13 form the password
    parameter [15:0] BPassword = 16'b0010_0001_0000_1111;
    wire hasBPassword;
    assign hasBPassword = (sw == BPassword);
    wire clk_4Hz;
    flexible_clock_divider clk_4Hz_gen(.main_clock(basys_clock), .ticks(12499999), .output_clock(clk_4Hz));
    wire [15:0] BLights;
    get_blinking_lights(.input_clock(clk_4Hz), .leds(BLights), .password(BPassword), .exclude(13));
    wire [15:0] B_oled;
    basic_task_b b_module(.basys_clock(basys_clock), .btnU(btnU), .btnC(btnC), .btnD(btnD), .pixel_index(pixel_index), .hasPassword(hasBPassword), .oled_data(B_oled));
    
    
    //Task C variables, blink at 3Hz (A0240152X)
    //Switches 0, 1, 2, 4, 5, 14
    parameter [15:0]CPassword = 16'b0100_0000_0011_0111;
    wire hasCPassword;
    assign hasCPassword = (sw == CPassword);
    wire clk_3Hz;
    flexible_clock_divider clock_3Hz(basys_clock, 16666666, clk_3Hz);
    wire [15:0] CLights;
    get_blinking_lights(.input_clock(clk_3Hz), .leds(CLights), .password(CPassword), .exclude(14));
    wire [15:0]C_oled;
    basic_task_c c_module(.basys_clock(basys_clock), .btnC(btnC), .hasPassword(hasCPassword), .pixel_index(pixel_index), .pixel_data(C_oled));
    
    
    //Task D variables, blink at 6Hz
    //switches 0, 1, 3, 5, 9, 15
    parameter [15:0]DPassword = 16'b1000_0010_0010_1011;
    wire hasDPassword;
    assign hasDPassword = (sw == DPassword);
    wire clk_6Hz;
    flexible_clock_divider clock_6Hz(basys_clock, 8333332, clk_6Hz);
    wire [15:0] DLights;
    get_blinking_lights(clk_6Hz, DLights, DPassword, 15);
    wire [15:0]D_oled;
    collision_module collision(
        .basys_clock(basys_clock),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .pixel_index(pixel_index),
        .oled_data(D_oled),
        .hasPassword(hasDPassword)
    );
    
    
    assign led = hasAPassword ? ALights : (hasBPassword ? BLights : (hasCPassword ? CLights : (hasDPassword ? DLights : sw)));
    
    // Logic for integration to control which subtask to render
    // wire isCircle = 1;
    assign oled_data = hasAPassword ? circle_oled : (hasBPassword? B_oled : (hasCPassword? C_oled: (hasDPassword ? D_oled : team_oled_data)));
    
    // Seven segment display for S207
    wire clk_500Hz;
    flexible_clock_divider clk_500Hz_gen(.main_clock(basys_clock), .ticks(99999), .output_clock(clk_500Hz));
    render_segments segments(.input_clock(clk_500Hz), .an(an), .seg(seg));
endmodule