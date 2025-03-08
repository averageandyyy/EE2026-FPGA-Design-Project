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


module Top_Student (input basys_clock, btnU, btnL, btnR, btnD, output [7:0]JB);
    wire clk6p25M;
    flexible_clock_divider unit_0 (basys_clock, 7, clk6p25M);
    wire [15:0]oled_data; //this is the color
    wire fb;
    wire sample_pixel;
    wire [12:0]pixel_index; //this is the coordinates
    wire sending_pixel;
    Oled_Display display(.clk(clk6p25M), 
        .reset(0), 
        .frame_begin(fb), 
        .sending_pixels(sending_pixel),
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
     collision collide(basys_clock, btnU, btnL, btnR, btnD, pixel_index, oled_data);
          
          
         
         
        

endmodule