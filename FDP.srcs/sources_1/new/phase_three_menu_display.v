`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 14:04:40
// Design Name: 
// Module Name: phase_three_menu_display
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
This module is merely responsible for showing the 2 button menu
for choosing between Table and Integration
*/
module phase_three_menu_display(
    input clock, //clk is 6p25MHz
    input [11:0] xpos, ypos,
    input mouse_left,
    input use_mouse, //use sw[0]
    input clk_100MHz,
    input [12:0] pixel_index,
    input cursor_row, // 0 = TABLE, 1 = INTG
    input btnC,
    output reg [15:0] oled_data
    );

    wire [6:0] x = pixel_index % 96;
    wire [6:0] y = pixel_index / 96;
        //debouncing for left mouse button
    parameter DEBOUNCE_DELAY = 2000000;
    reg [21:0] counter;    // Counter for debounce delay (needs enough bits)
    reg debounced;         // Stores the debounced state
    initial begin
        counter   = 0;
        debounced = 1'b0;
    end
    always @(posedge clk_100MHz) begin
            if (mouse_left == debounced) 
                counter <= 0;
            else begin
                counter <= counter + 1;
                if (counter >= DEBOUNCE_DELAY) debounced <= mouse_left;
            
            end
    end
    reg mouse_left_prev;
    initial begin mouse_left_prev = 1'b0; end
    // Drawing the menu
    always @(posedge clock) begin
        // Set default background
        oled_data <= 16'b0;
        
        // Display the function title at top
        if ((y >= 5 && y <= 11) && (x >= 15 && x <= 81)) begin
            // Draw "FUNCTION MODE" text
            
            // --- "F" ---
            if ((x >= 15 && x <= 20 && y == 5) || 
                (x == 15 && y >= 5 && y <= 11) || 
                (x >= 15 && x <= 18 && y == 8))
                oled_data <= 16'b11111_111111_11111;
                
            // --- "U" ---
            if ((x == 22 && y >= 5 && y <= 11) || 
                (x == 26 && y >= 5 && y <= 11) || 
                (x >= 22 && x <= 26 && y == 11))
                oled_data <= 16'b11111_111111_11111;
                
            // --- "N" ---
            if ((x == 28 && y >= 5 && y <= 11) || 
                (x == 32 && y >= 5 && y <= 11) || 
                (x == 29 && y == 6) || 
                (x == 30 && y == 7) || 
                (x == 31 && y == 8))
                oled_data <= 16'b11111_111111_11111;
                
            // --- "C" ---
            if ((x == 34 && y >= 5 && y <= 11) || 
                (x >= 34 && x <= 38 && y == 5) || 
                (x >= 34 && x <= 38 && y == 11))
                oled_data <= 16'b11111_111111_11111;
                
            // --- "T" ---
            if ((x >= 40 && x <= 44 && y == 5) || 
                (x == 42 && y >= 5 && y <= 11))
                oled_data <= 16'b11111_111111_11111;
                
            // --- "I" ---
            if ((x >= 46 && x <= 50 && y == 5) || 
                (x >= 46 && x <= 50 && y == 11) || 
                (x == 48 && y >= 5 && y <= 11))
                oled_data <= 16'b11111_111111_11111;
                
            // --- "O" ---
            if ((x == 52 && y >= 5 && y <= 11) || 
                (x == 56 && y >= 5 && y <= 11) || 
                (x >= 52 && x <= 56 && y == 5) || 
                (x >= 52 && x <= 56 && y == 11))
                oled_data <= 16'b11111_111111_11111;
                
            // --- "N" ---
            if ((x == 58 && y >= 5 && y <= 11) || 
                (x == 62 && y >= 5 && y <= 11) || 
                (x == 59 && y == 6) || 
                (x == 60 && y == 7) || 
                (x == 61 && y == 8))
                oled_data <= 16'b11111_111111_11111;
                
            // --- "M" ---
            if ((x == 64 && y >= 5 && y <= 11) || 
                (x == 68 && y >= 5 && y <= 11) || 
                (x == 65 && y == 6) || 
                (x == 66 && y == 7) || 
                (x == 67 && y == 6))
                oled_data <= 16'b11111_111111_11111;
                
            // --- "O" ---
            if ((x == 70 && y >= 5 && y <= 11) || 
                (x == 74 && y >= 5 && y <= 11) || 
                (x >= 70 && x <= 74 && y == 5) || 
                (x >= 70 && x <= 74 && y == 11))
                oled_data <= 16'b11111_111111_11111;
                
            // --- "D" ---
            if ((x == 76 && y >= 5 && y <= 11) || 
                (x == 80 && y >= 6 && y <= 10) || 
                (x >= 76 && x <= 79 && y == 5) || 
                (x >= 76 && x <= 79 && y == 11))
                oled_data <= 16'b11111_111111_11111;
                
            // --- "E" ---
            if ((x == 82 && y >= 5 && y <= 11) || 
                (x >= 82 && x <= 86 && y == 5) || 
                (x >= 82 && x <= 85 && y == 8) || 
                (x >= 82 && x <= 86 && y == 11))
                oled_data <= 16'b11111_111111_11111;
        end
        
        // TABLE button (top option)
        if ((y >= 20 && y <= 30) && (x >= 30 && x <= 66)) begin
            if ((btnC || (use_mouse && debounced && !mouse_left_prev)) && cursor_row == 0) begin
                oled_data <= 16'b00000_111111_00000; // Green when selected
            end
            else begin
                // Draw borders
                if ((x >= 30 && x <= 66 && y == 20) || (x >= 30 && x <= 66 && y == 30))
                    oled_data <= 16'b11111_111111_11111;
                if ((y >= 20 && y <= 30 && x == 30) || (y >= 20 && y <= 30 && x == 66))
                    oled_data <= 16'b11111_111111_11111;
                    
                // "TABLE" text
                // "T"
                if ((x >= 34 && x <= 40 && y == 23) || (x == 37 && y >= 23 && y <= 27))
                    oled_data <= 16'b11111_111111_11111;
                    
                // "A"
                if ((x >= 42 && x <= 46 && y == 23) || 
                    (x == 42 && y >= 23 && y <= 27) || 
                    (x == 46 && y >= 23 && y <= 27) || 
                    (x >= 42 && x <= 46 && y == 25))
                    oled_data <= 16'b11111_111111_11111;
                    
                // "B"
                if ((x == 48 && y >= 23 && y <= 27) || 
                    (x >= 48 && x <= 51 && y == 23) || 
                    (x >= 48 && x <= 51 && y == 25) || 
                    (x >= 48 && x <= 51 && y == 27) || 
                    (x == 52 && y >= 23 && y <= 25) || 
                    (x == 52 && y >= 25 && y <= 27))
                    oled_data <= 16'b11111_111111_11111;
                    
                // "L"
                if ((x == 54 && y >= 23 && y <= 27) || 
                    (x >= 54 && x <= 58 && y == 27))
                    oled_data <= 16'b11111_111111_11111;
                    
                // "E"
                if ((x == 60 && y >= 23 && y <= 27) || 
                    (x >= 60 && x <= 63 && y == 23) || 
                    (x >= 60 && x <= 62 && y == 25) || 
                    (x >= 60 && x <= 63 && y == 27))
                    oled_data <= 16'b11111_111111_11111;
            end
        end
        
        // INTG button (bottom option)
        if ((y >= 35 && y <= 45) && (x >= 30 && x <= 66)) begin
            if ((btnC || (use_mouse && debounced && !mouse_left_prev)) && cursor_row == 1) begin
                oled_data <= 16'b00000_111111_00000; // Green when selected
            end
            else begin
                // Draw borders
                if ((x >= 30 && x <= 66 && y == 35) || (x >= 30 && x <= 66 && y == 45))
                    oled_data <= 16'b11111_111111_11111;
                if ((y >= 35 && y <= 45 && x == 30) || (y >= 35 && y <= 45 && x == 66))
                    oled_data <= 16'b11111_111111_11111;
                    
                // "INTG" text
                // "I"
                if ((x >= 35 && x <= 39 && y == 38) || 
                    (x >= 35 && x <= 39 && y == 42) || 
                    (x == 37 && y >= 38 && y <= 42))
                    oled_data <= 16'b11111_111111_11111;
                    
                // "N"
                if ((x == 42 && y >= 38 && y <= 42) || 
                    (x == 46 && y >= 38 && y <= 42) || 
                    (x == 43 && y == 39) || 
                    (x == 44 && y == 40) || 
                    (x == 45 && y == 41))
                    oled_data <= 16'b11111_111111_11111;
                    
                // "T"
                if ((x >= 48 && x <= 54 && y == 38) || 
                    (x == 51 && y >= 38 && y <= 42))
                    oled_data <= 16'b11111_111111_11111;
                    
                // "G"
                if ((x == 56 && y >= 38 && y <= 42) || 
                    (x >= 56 && x <= 60 && y == 38) || 
                    (x >= 56 && x <= 60 && y == 42) || 
                    (x == 60 && y >= 40 && y <= 42) ||
                    (x >= 58 && x <= 60 && y == 40))
                    oled_data <= 16'b11111_111111_11111;
            end
        end
        
        // Arrow indicating user selection position
        if (x >= 26 && x <= 28) begin
            if (cursor_row == 0) begin
                if (y >= 24 && y <= 26 && (x == 26 || x == 27))
                    oled_data <= 16'b11111_111111_11111;
                if (y == 25 && x == 28)
                    oled_data <= 16'b11111_111111_11111;
            end
            else if (cursor_row == 1) begin
                if (y >= 39 && y <= 41 && (x == 26 || x == 27))
                    oled_data <= 16'b11111_111111_11111;
                if (y == 40 && x == 28)
                    oled_data <= 16'b11111_111111_11111;
            end
        end
        mouse_left_prev <= debounced;
    end
endmodule
