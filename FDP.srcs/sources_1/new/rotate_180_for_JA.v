`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2025 14:42:53
// Design Name: 
// Module Name: rotate_180_for_JA
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


module rotate_180_for_JA(
    input  wire [12:0] pixel_index,        // Original pixel index (0 to 6143)
    output wire [12:0] rotated_pixel_index // Rotated pixel index (0 to 6143)
);

    // Compute x and y coordinates for a 96x64 display.
    // x is 0 to 95, y is 0 to 63.
    wire [6:0] x, y;
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;

    // For a 180-degree rotation, flip both x and y.
    wire [6:0] x_rot, y_rot;
    assign x_rot = 7'd95 - x;
    assign y_rot = 7'd63 - y;

    // Compute the new pixel index.
    // rotated_pixel_index = y_rot * 96 + x_rot
    assign rotated_pixel_index = y_rot * 96 + x_rot;

endmodule

