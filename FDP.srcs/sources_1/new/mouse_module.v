`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2025 15:11:37
// Design Name: 
// Module Name: mouse_module
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


module mouse_module (
    input  wire             clk,       // 100 MHz clock
    input  wire             rst,       // Reset signal
    input  wire [11:0]      value,     // 12-bit setting value
    input wire setmax_x, input wire setmax_y, input wire setx, input wire sety,
    inout  wire             ps2_clk,   // PS/2 clock line
    inout  wire             ps2_data,  // PS/2 data line
    output wire [11:0]      xpos,      // Mouse X output
    output wire [11:0]      ypos,      // Mouse Y output
    output wire [3:0]       zpos,      // Mouse scroll wheel output
    output wire             left,      // Left button
    output wire             middle,    // Middle button
    output wire             right,     // Right button
    output wire             new_event  // Indicates new mouse event
);
  initial begin
    
  end
  // Instantiate the VHDL MouseCtl module
  // The generics here match the defaults in MouseCtl.vhd
  MouseCtl #(
    .SYSCLK_FREQUENCY_HZ(100000000),
    .CHECK_PERIOD_MS(500),
    .TIMEOUT_PERIOD_MS(100)
  ) mouse_inst (
    .clk       (clk),
    .rst       (rst),
    .xpos      (xpos),
    .ypos      (ypos),
    .zpos      (zpos),
    .left      (left),
    .middle    (middle),
    .right     (right),
    .new_event (new_event),
    .value     (value),
    .setx      (setx),
    .sety      (sety),
    .setmax_x  (setmax_x),
    .setmax_y  (setmax_y),
    .ps2_clk   (ps2_clk),
    .ps2_data  (ps2_data)
  );

endmodule