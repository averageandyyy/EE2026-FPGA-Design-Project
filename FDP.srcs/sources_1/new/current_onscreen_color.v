`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2025 17:08:27
// Design Name: 
// Module Name: current_onscreen_color
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


module current_onscreen_color (
    input  wire [12:0] pixel_index,  // 13-bit pixel index (0 to 6143)
    output reg  [15:0] bg_color   // 16-bit RGB565 color for that pixel
);

    // Declare a simple framebuffer with 6144 (96*64) entries
    reg [15:0] frame_buffer [0:6143];

    // Initialize the framebuffer with some "original" colors.
    // For real hardware, the memory would be updated by another process.

    // Combinationally read the pixel color from the framebuffer.
    always @(*) begin
        bg_color = frame_buffer[pixel_index];
    end

endmodule