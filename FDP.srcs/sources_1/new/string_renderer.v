`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2025 01:30:57
// Design Name: 
// Module Name: string_renderer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module string_renderer(
    input clk,
    //6 bits for 8 words
    input [48:0] word, 
    
    // Starting coordinates
    input [6:0] start_x,      
    input [5:0] start_y,
    input [12:0] pixel_index,
    
    //Colour of word
    input [15:0] colour,   
    
    //Pixel status 
    output reg [15:0] oled_data,   
    output reg active_pixel      
);

    parameter CHAR_WIDTH = 6; 
    
    wire [15:0] char_data [7:0]; 
    wire pixel_active [7:0];  
    
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : renderers
            sprite_renderer renderer_inst (
                .clk(clk),
                .pixel_index(pixel_index),
                .character(word[(i+1)*6-1:i*6]), 
                .start_x(start_x + ((7 - i) * (1 + CHAR_WIDTH))),
                .start_y(start_y),
                .colour(colour),
                .oled_data(char_data[i]),
                .active_pixel(pixel_active[i])
            );
        end
    endgenerate
    
    integer j;
    
    always @(*) begin
        oled_data = 16'b0;
        active_pixel = 0;
        
        for (j = 0; j < 8; j = j + 1) begin
            if (pixel_active[j]) begin
                oled_data = char_data[j];
                active_pixel = 1;
            end
        end
    end

endmodule

