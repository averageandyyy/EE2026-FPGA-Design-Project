`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2025 19:24:39
// Design Name: 
// Module Name: test_picture
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


module test_picture (
    input  wire [12:0] pixel_index,  // 13-bit pixel index (0 to 6143)
    output reg  [15:0] pixel_color   // 16-bit RGB565 color for that pixel
);

      // Framebuffer: one entry per pixel.
reg [15:0] frame_buffer [0:6143];
integer i;
integer x_int, y_int;
real x, y, expr_left, expr_right;

// Define colors in RGB565 format.
localparam [15:0] RED   = 16'b11111_000000_00000; // 0xF800: pure red
localparam [15:0] WHITE = 16'b11111_111111_11111; // 0xFFFF: pure white

initial begin
    // Loop through all 6144 pixels.
    for (i = 0; i < 6144; i = i + 1) begin
        // Compute pixel coordinates (x_int from 0 to 95, y_int from 0 to 63)
        x_int = i % 96;
        y_int = i / 96;
        
        // Map display coordinates to a Cartesian coordinate system:
        //   x: 0 .. 95  -->  -1.5 to +1.5
        //   y: 0 .. 63  -->  +1.5 (top) to -1.5 (bottom)
        x = (x_int * 3.0 / 95.0) - 1.5;
        y = 1.5 - (y_int * 3.0 / 63.0);
        
        // Compute the left-hand side of the inequality: (x^2 + y^2 - 1)^3
        expr_left = (x*x + y*y - 1.0);
        expr_left = expr_left * expr_left * expr_left;
        
        // Compute the right-hand side: x^2 * y^3
        expr_right = x*x * (y*y*y);
        
        // If the inequality holds, the pixel is part of the heart.
        if (expr_left < expr_right)
            frame_buffer[i] = RED;
        else
            frame_buffer[i] = WHITE;
    end
end

// Combinationally read the pixel color from the framebuffer.
always @(*) begin
    pixel_color = frame_buffer[pixel_index];
end
endmodule