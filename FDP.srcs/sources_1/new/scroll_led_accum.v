`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.04.2025 17:33:32
// Design Name: 
// Module Name: scroll_led_accum
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


module scroll_led_accum(
    input        clk,         // system clock (e.g., 100 MHz)
    input        rst,         // active-high reset
    input        new_event,   // one-clock-cycle pulse when a scroll event occurs
    input  [3:0] zpos,        // scroll wheel delta 
                              // (assumed: 4'b1111 = -1, 4'b0001 = +1)
    output reg [1:0] wow // 4-bit LED output (expected 0 to 15)
);

    // 4-bit counter that tracks the current value.
    reg [1:0] counter;
    
    initial begin
        counter = 2'b00;
        wow = 4'b0000;
    end

    // Latch new_event and zpos for one clock cycle, then update counter.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 2'b00;
        end
        else if (new_event) begin
            if (zpos == 4'b0001)
                counter <= 10;  // scroll up ? increment
            else if (zpos == 4'b1111)
                counter <= 01;  // scroll down ? decrement
            else
                counter <= 00;
        end
    end

    // Update LED pattern based on the counter.
    always @(posedge clk) begin
        wow <= counter;
    end

endmodule