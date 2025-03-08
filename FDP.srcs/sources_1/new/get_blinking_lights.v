`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2025 20:14:04
// Design Name: 
// Module Name: get_blinking_lights
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


module get_blinking_lights(
    input input_clock,
    output reg [15:0]leds,
    input [15:0]password,
    input [3:0]exclude
    );
    
    initial begin
        leds = password;
    end
    
    // Toggle password leds and leave the excluded one on
    always @ (posedge input_clock)
    begin
        leds = ~leds & password;
        leds[exclude] = 1'b1;
    end
    
endmodule
