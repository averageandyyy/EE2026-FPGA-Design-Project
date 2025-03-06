`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2025 08:27:28
// Design Name: 
// Module Name: circle_module
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

/*
Circle Display Controller Module
--------------------------------
This module renders a circle on a 96x64 OLED display with interactive controls.

Display States:
- State 0: Only red border around display edge
- States 1-9: Red border + green circle ring with increasing diameters:
  * State 1: 10px diameter
  * State 2: 15px diameter
  * State 3: 20px diameter
  * State 4: 25px diameter  
  * State 5: 30px diameter
  * State 6: 35px diameter
  * State 7: 40px diameter
  * State 8: 45px diameter
  * State 9: 50px diameter

Controls:
- Center button (btnC): Transitions from state 0 to state 5
- Up button (btnU): Increases state/diameter (when in states 1-9)
- Down button (btnD): Decreases state/diameter (when in states 1-9)

Note: After initial transition, state 0 becomes unreachable (transient).
*/
module circle_module(
    input basys_clock,
    input [12:0]pixel_index,
    output reg [15:0]oled_data,
    input btnC,
    input btnU,
    input btnD
    );
    
    // 1KHz clock for debouncing
    wire clk_1k;
    flexible_clock_divider clk_1k_gen(.main_clock(basys_clock), .ticks(49999), .output_clock(clk_1k));
    
    // Debouncing variables
    reg [7:0]debounce_U;
    reg [7:0]debounce_C;
    reg [7:0]debounce_D;
    reg prev_U;
    reg prev_C;
    reg prev_D;
    
    // State variables
    reg [3:0]state;
    reg [11:0]diameter;
    wire [11:0]radius;
    wire [11:0]inner_radius;
    wire [15:0]r_squared;
    wire [15:0]ir_squared;
    assign radius = diameter / 2;
    assign inner_radius = radius - 5/2;
    assign r_squared = radius * radius;
    assign ir_squared = inner_radius * inner_radius;
    
    // Colour parameters
    parameter [15:0]RED = 16'b11111_000000_00000;
    parameter [15:0]GREEN = 16'b00000_111111_00000;
    
    // Variables to hold pixel coordinates
    wire [6:0]x;
    wire [6:0]y;
    wire signed [6:0]circle_x;
    wire signed [6:0]circle_y;
    wire [15:0]x_squared;
    wire [15:0]y_squared;

    
    // Initialize variables
    initial begin
        state = 4'b0;
        diameter = 12'b0;
        debounce_C = 8'b0;
        debounce_U = 8'b0;
        debounce_D = 8'b0;
        prev_C = 1'b0;
        prev_U = 1'b0;
        prev_D = 1'b0;
        oled_data = 16'b0;
    end
    
    // Obtain pixel coordinates 96x64
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    assign circle_x = x - 47;
    assign circle_y = y - 31;
    assign x_squared = circle_x * circle_x;
    assign y_squared = circle_y * circle_y;
    
    // Loop to update colour to render
    always @ (posedge basys_clock)
    begin
        // Red Border Bounds
        if ((y == 2 && x > 1 && x < 94) || (x == 2 && y > 1 && y < 62) || (y == 61 && x > 1 && x < 94) || (x == 93 && y > 1 && y < 62)) begin
            oled_data <= RED;
        end
        else if (((x_squared + y_squared) <= r_squared) && ((x_squared + y_squared) >= ir_squared)) begin
            oled_data <= GREEN;
        end
        else begin
            oled_data <= 16'b0;
        end
    end
    
    // Loop to update diameter
    always @ (posedge basys_clock)
    begin
        if (state == 1) begin
            diameter <= 10;
        end
        else if (state == 2) begin
            diameter <= 15;
        end
        else if (state == 3) begin
            diameter <= 20;
        end
        else if (state == 4) begin
            diameter <= 25;
        end
        else if (state == 5) begin
            diameter <= 30;
        end
        else if (state == 6) begin
            diameter <= 35;
        end
        else if (state == 7) begin
            diameter <= 40;
        end
        else if (state == 8) begin
            diameter <= 45;
        end
        else if (state == 9) begin
            diameter <= 50;
        end
    end

    // Loop to update state
    always @ (posedge clk_1k)
    begin
        if (debounce_C > 0) begin
            debounce_C <= debounce_C - 1;
        end
        if (debounce_U > 0) begin
            debounce_U <= debounce_U - 1;
        end
        if (debounce_D > 0) begin
            debounce_D <= debounce_D - 1;
        end

        // Transition from state 0 to 5;
        if (btnC && !prev_C && debounce_C == 0 && state == 0) begin
            state <= 5;
            debounce_C <= 200;
        end

        if (btnU && !prev_U && debounce_U == 0 && state < 9 && state >= 1) begin
            state <= state + 1;
            debounce_U <= 200;
        end

        if (btnD && !prev_D && debounce_D == 0 && state <= 9 && state > 1) begin
            state <= state - 1;
            debounce_D <= 200;
        end

        prev_C <= btnC;
        prev_U <= btnU;
        prev_D <= btnD;
    end
endmodule
