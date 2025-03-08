`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2025 12:00:00
// Design Name: 
// Module Name: collision
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


module collision(input basys_clock, btnu, btnl, btnr, btnd,
    input [12:0]pixel_idx,
    output reg [15:0]oled_data);
//for coordinates
    wire [6:0] x;
    wire [6:0] y;
    assign x = pixel_idx % 96;
    assign y = pixel_idx / 96;
    
    //initial square position
    //square formed will be curr_x + 9 and curr_y + 9
    reg [6:0] curr_x = 0;
    reg [6:0] curr_y = 53;
    
    // Colour parameters
    parameter [15:0]RED = 16'b11111_000000_00000;
    parameter [15:0]GREEN = 16'b00000_111111_00000;
    
    //update the btn state every 1ms --> 1000Hz
    wire clk1kHz;
    flexible_clock_divider unit_0 (basys_clock, 49999, clk1kHz);
    
    //initial 30*30 red box and 10*10 green box
    always @ (posedge basys_clock) begin
        if (x <=95 && x >= 65 && y >= 0 && y <= 30) begin
            oled_data <= RED;
        end
        
        else if (x >= curr_x && x < curr_x + 10
         && y >= curr_y && y < curr_y + 10) begin
            oled_data <= GREEN;
        end    
        else oled_data <= 16'b0;
    end
    
    
    reg [1:0] direction;
    //left= 00, right = 01, up = 10, down = 11
    //check for btn state
    always @ (posedge clk1kHz) begin
        if (btnr) begin
            direction <= 2'b01;
        end
        else if (btnu) begin
            direction <= 2'b10;    
        end
        else if (btnl) begin
            direction <= 2'b00;    
        end
        else if (btnd) begin
            direction <= 2'b11;    
        end
    end
    
    //find current box position
    //initialize the square at the bottom-left corner
    //we want to track the top left corner of the square.
    
    
    
    //animation
    wire clk_30Hz;
    flexible_clock_divider unit_1 (basys_clock, 1666666, clk_30Hz);
    always @ (posedge clk_30Hz) begin
        if (direction == 2'b01 && (curr_x < 86)) begin
            if (curr_y >= 30) curr_x <= curr_x + 1; //able to move right
            else if (curr_x < 55) curr_x <= curr_x + 1;
        end
        else if (direction == 2'b00 && (curr_x > 0)) 
            curr_x <= curr_x - 1; //able to move left
        else if (direction == 2'b10 && curr_y > 0) begin
            if (curr_x <= 55) curr_y <= curr_y - 1; 
            else if ((curr_y) > 31) //check top left edge for collision
                curr_y <= curr_y - 1; //able to move up
        end
            //else if (curr_y <= 31) curr_y <= curr_y - 1;
        //end
        else if (direction == 2'b11 && (curr_y < 53))
            curr_y <= curr_y + 1; //able to move down
            
    
    end






endmodule
