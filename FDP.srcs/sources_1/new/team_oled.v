`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2025 19:43:24
// Design Name: 
// Module Name: team_oled
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


module team_oled(
    input [12:0]pixel_index,
    output reg [15:0]oled_data
    );
    
    initial begin
        oled_data = 16'b0;
    end
    
    parameter [15:0]WHITE = 16'hFFFF;
    
    wire [6:0]x;
    wire [6:0]y;
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    // Digit positioning (full screen)
    // Each digit takes up approximately half the screen width
    // Drawing loop 
    always @ (*) begin
        // Default - black background
        oled_data = 16'b0;
        
        // Draw digit "0" (10-40, 5-59)
        if ((x >= 7 && x <= 43 && ((y >= 5 && y <= 11) || (y >= 53 && y <= 59))) ||  // Top and bottom thick lines
            ((x >= 7 && x <= 13) || (x >= 37 && x <= 43)) && y >= 5 && y <= 59) begin // Left and right thick lines
            oled_data = WHITE;
        end
        
        // Draw digit "7" (55-85, 5-59)
        else if ((x >= 52 && x <= 85 && y >= 5 && y <= 11) ||        // Top thick line
                 (x >= ((85 - ((y - 5) * 5) / 9) - 3) && 
                  x <= ((85 - ((y - 5) * 5) / 9) + 3) && 
                  y >= 5 && y <= 59)) begin // Diagonal thick line, formula basically y = mx + c or y = -9/5 x + 158, with y bounds
            oled_data = WHITE;
        end
    end
endmodule
