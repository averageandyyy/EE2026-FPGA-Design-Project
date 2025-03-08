`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2025 21:26:02
// Design Name: 
// Module Name: grptask_D
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


module grptask_D(input [15:0] password, input clock, output reg [15:0] LEDS);

initial begin
    LEDS = password;
end


always @ (posedge clock) begin 
    LEDS[0] <= ~LEDS[0];
    LEDS[1] <= ~LEDS[1];
    LEDS[9] <= ~LEDS[9];
    LEDS[5] <= ~LEDS[5];
    LEDS[3] <= ~LEDS[3];
end



endmodule
