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
    
    
    // 25MHz clock for screen display
    wire clk_25MHz;
    flexible_clock_divider clk_25MHz_gen(
        .main_clock(basys_clock),
        .ticks(7),
        .output_clock(clk_25MHz)
    );
    
    //wire pixel_x;
    //wire pixel_y;
    //assign pixel_x = one_pixel_index % 96;
    //assign pixel_y = one_pixel_index / 96;
    
    localparam max_x = 96;
    localparam max_y = 64;
    reg [15:0] final_color;
    
    // Declare wires for active pixels and their corresponding colors for each number/sprite
    wire [15:0] number1_color, number2_color;
    wire number1_active, number2_active;
    
    // Instantiate number sprites at different positions
    sprite_renderer number1 (
        .clk(clk_25MHz),
        .pixel_index(one_pixel_index),
        .digit(4'b1011), // Digit to display
        .start_x(30), // X position
        .start_y(40), // Y position
        .colour(16'b11111_000_00000), // Colour (e.g., red)
        .oled_data(number1_color),
        .active_pixel(number1_active),
        .led(led)
    );

    sprite_renderer number2 (
        .clk(clk_25MHz),
        .pixel_index(pixel_index),
        .digit(4'b1011), // Digit to display
        .start_x(20), // X position (offset from number1)
        .start_y(20),  // Y position
        .colour(16'b00000_111111_00000), // Colour (e.g., green)
        .oled_data(number2_color),
        .active_pixel(number2_active),
        .led(led)
    );

    // Combine the pixel data from all sprites
    assign one_oled_data = number1_color ; //|| number2_color; // Default to white (background)

        


endmodule