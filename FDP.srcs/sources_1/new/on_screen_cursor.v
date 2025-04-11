`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2025 14:00:39
// Design Name: 
// Module Name: on_screen_cursor
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


module on_screen_cursor(input basys_clock, input [12:0] pixel_index, input graph_mode_check, input setmax_x, input setmax_y, input setx, input sety,
input [11:0] xpos, ypos, value, output reg [15:0] oled_data, input [15:0] bg_data,
output reg [6:0] cursor_x,  // New output: current x (0-95)
output reg [6:0] cursor_y
    );

    wire [7:0] curr_x;
    wire [7:0] curr_y;
    assign curr_x = pixel_index % 96;
    assign curr_y = pixel_index / 96;
    
    parameter [15:0] GREEN = 16'b00000_111111_00000;
    parameter [15:0] BLACK = 16'b00000_000000_00000;
    reg [7:0] x = 0;
    reg [7:0] y = 0;
    //cursor always starts from the top, this reg tracks the top left corner of the cursor.
    
    //cursor initial state
    always @(posedge basys_clock) begin
        if (graph_mode_check) begin
            if ((curr_x >= x) && (curr_x < x + 8) &&
                (curr_y >= y) && (curr_y < y + 11)) begin
                if ((curr_y - y) < 8) begin
                    // Arrow head: a left-aligned triangle.
                    if ((curr_x - x) <= (curr_y - y))
                        oled_data <= GREEN;
                    else
                        oled_data <= bg_data;
                end else begin
                    // Tail: trapezoidal shape.
                    // Let dy = curr_y - y, for dy in [8, 12)
                    // Define left_bound = x + 2 + (dy - 8)
                    // and right_bound = x + 6 + (dy - 8)
                     if ((curr_x >= (x + 3 + ((curr_y - y) - 8))) && 
                     (curr_x <  (x + 5 + ((curr_y - y) - 8))))
                        oled_data <= GREEN;
                    else
                        oled_data <= bg_data;
                end
            end else begin
                oled_data <= bg_data;
            end
        end else begin
            oled_data <= bg_data;
        end
    end
    
    reg [7:0] max_x = 8'd95;
    reg [7:0] max_y = 8'd63;
    //movement of cursor based on mouse movement
      always @(posedge basys_clock) begin
          if (graph_mode_check) begin
              // Update maximum values if the control signals are asserted.
              if (setmax_x)
                  max_x <= value[7:0];
              if (setmax_y)
                  max_y <= value[7:0];
              
              // Update x position: if setx is asserted, use value; otherwise, use the mouse position.
              if (setx)
                  x <= value[7:0];
              else begin
                  // Clip the mouse_xpos (12 bits) to a maximum of 95.
                  if (xpos >= 12'd96)
                      x <= max_x;
                  else
                      x <= xpos[7:0];
              end
              
              // Update y position: if sety is asserted, use value; otherwise, use the mouse position.
              if (sety)
                  y <= value[7:0];
              else begin
                  // Clip the mouse_ypos (12 bits) to a maximum of 63.
                  if (ypos >= 12'd64)
                      y <= max_y;
                  else
                      y <= ypos[7:0];
              end
              cursor_x <= x[6:0];
              cursor_y <= y[6:0];
            end
            
        end
    
endmodule