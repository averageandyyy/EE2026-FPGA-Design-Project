`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2025 20:10:26
// Design Name: 
// Module Name: mouse_coordinate_extractor
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


module mouse_coordinate_extractor(
    input         basys_clock, //6p25MHz clock
    input  [11:0] xpos,    // 12-bit mouse x position
    input  [11:0] ypos,    // 12-bit mouse y position
    output reg [6:0] mouse_x,  // 7-bit mouse x (0-95)
    output reg [6:0] mouse_y   // 7-bit mouse y (0-63)
);

    always @(posedge basys_clock) begin
        // Clip xpos: if xpos >= 96, set mouse_x to 95; otherwise, use lower 7 bits.
        if (xpos >= 12'd96)
            mouse_x <= 7'd95;
        else
            mouse_x <= xpos[6:0];
            
        // Clip ypos: if ypos >= 64, set mouse_y to 63; otherwise, use lower 7 bits.
        if (ypos >= 12'd64)
            mouse_y <= 7'd63;
        else
            mouse_y <= ypos[6:0];
    end

endmodule
