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

    wire graph_active;
    wire [15:0] graph_oled_data; 
    reg zoom_level = 1;
    reg [6:0]pan_x = 40;
    reg [5:0]pan_y = 20;
    
    graph_display graph (
        .clk(clk_6p25MHz),
        .pixel_index(one_pixel_index),
        .zoom_level(3'b001),    // Simple zoom by Danial
        .pan_offset_x(pan_x),  // Signed panning control
        .pan_offset_y(pan_y),
        .coeff_1(sw[15:12]),
        .coeff_2(sw[11:8]),
        .coeff_3(sw[7:4]),
        .coeff_4(sw[3:0]),
        .colour(16'hF800), 
        .oled_data(graph_oled_data), // OLED pixel data (RGB 565 format)
        .oled_valid(graph_active)
    );
    
    reg prevBtnU = 0;
    reg prevBtnD = 0;
    reg prevBtnL = 0;
    reg prevBtnR = 0;
    reg prevBtnC = 0;
    
            
    always @ (posedge clk_6p25MHz) begin
//        if (prevBtnC & ~btnC) begin
//            zoom_level <= (zoom_level > 2)? 0 : zoom_level + 1;
//        end
        
        if (prevBtnU & ~btnU) begin
            pan_y <= (pan_y >= 90)? 90 : pan_y + 2;
        end
        
        if (prevBtnD & ~btnD) begin
            pan_y <= (pan_y <= 10)? 10 : pan_y - 2;
        end
        
        if (prevBtnL & ~btnL) begin
           pan_x <= (pan_x <= 10)? 10 : pan_x - 2;
        end
        
        if (prevBtnR & ~btnR) begin
            pan_x <= (pan_x >= 90)? 90 : pan_x + 2;
        end
        
        prevBtnU <= btnU;
        prevBtnD <= btnD;
        prevBtnL <= btnL;
        prevBtnR <= btnR;
        
        prevBtnC <= btnC;
    end

    // Combine the pixel data from all sprites
    assign one_oled_data = graph_active ? graph_oled_data :
                           16'hFFFF; // Background
endmodule