`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 09:49:44
// Design Name: 
// Module Name: phase_two_menu_display
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
This module renders the second phase menu, that is, where the user chooses
between arithmetic or function

From wayne's design it appears to be stacked on top? so only rows matter
to check
*/
module phase_two_menu_display(
    input clock,
    input [12:0] pixel_index,
    output reg [15:0] oled_data,
    input cursor_row, // Only 2 options
    input btnC,
    input [6:0] curr_x, curr_y,
    input mouse_left,
    input clk_100MHz
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
    always @ (posedge clock) begin
        oled_data <= 16'b0;
        // Write START at the top
        // Draw start
        if ((y >= 5 && y <= 11)) begin 
            // --- "S" ---
            if ((x >= 33 && x <= 38 && y == 5) ||  // Top stroke
                (x == 33 && y >= 5 && y <= 8) ||  // Left vertical
                (x >= 33 && x <= 38 && y == 8) ||  // Middle stroke
                (x == 38 && y >= 8 && y <= 11) ||  // Right vertical
                (x >= 33 && x <= 38 && y == 11))    // Bottom stroke
                oled_data <= 16'b11111_111111_11111;
            
            // --- "T" ---
            if ((x >= 40 && x <= 45 && y == 5) ||  // Top stroke
                (x == 42 && y >= 5 && y <= 11))    // Vertical stroke
                oled_data <= 16'b11111_111111_11111;
            
            // --- "A" ---
            if ((x >= 47 && x <= 52 && y == 5) ||  // Top arc
                (x == 47 && y >= 5 && y <= 11) ||  // Left vertical
                (x == 52 && y >= 5 && y <= 11) ||  // Right vertical
                (x >= 47 && x <= 52 && y == 8))    // Middle stroke
                oled_data <= 16'b11111_111111_11111;
            
            // --- "R" ---
            if ((x == 54 && y >= 5 && y <= 11) ||  // Vertical stroke
                (x >= 54 && x <= 59 && y == 5) ||  // Top stroke
                (x == 59 && y >= 5 && y <= 8) ||  // Right Vertical stroke
                (y == 8 && x >= 54 && x <= 59) ||  // Middle stroke
                (x == 59 && y >= 10 && y <= 11) ||  // Diagonal leg
                (x == 58 && y == 9))  
                oled_data <= 16'b11111_111111_11111;
            
            // --- "T" (again) ---
            if ((x >= 61 && x <= 66 && y == 5) ||  // Top stroke
                (x == 63 && y >= 5 && y <= 11))    // Vertical stroke
                oled_data <= 16'b11111_111111_11111;
        end
            
        // function button
        if ((y >= 15 && y <= 25) && (x >= 32 && x <= 66)) begin 
            if ((btnC || (debounced && !mouse_left_prev && curr_x >= 32 && curr_x <= 66 & curr_y >= 15 && curr_y <= 24)) && cursor_row == 0) begin
                oled_data <= 16'b00000_111111_00000; // Green when selected   
            end
            else begin
                // Draw borders first
                if ((x >= 32 && x <= 66 && y == 15) || (x >= 32 && x <= 66 && y == 24))
                    oled_data <= 16'b11111_111111_11111;
                if ((y >= 15 && y <= 24 && x == 32) || (y >= 15 && y <= 24 && x == 66))
                    oled_data <= 16'b11111_111111_11111;                
                
                // --- "F" ---
                if ((x == 34 && y >= 17 && y <= 21) ||   // Vertical stroke
                    (x >= 34 && x <= 36 && y == 17) ||   // Top stroke
                    (x >= 34 && x <= 36 && y == 19))     // Middle stroke
                    oled_data <= 16'b11111_111111_11111;
                        
                // --- "U" ---
                if ((x == 38 && y >= 17 && y <= 21) ||   // Left vertical stroke
                    (x == 40 && y >= 17 && y <= 21) ||   // Right vertical stroke
                    (x >= 38 && x <= 40 && y == 21))     // Bottom stroke
                    oled_data <= 16'b11111_111111_11111;
                    
                // --- "N" ---
                if ((x == 42 && y >= 17 && y <= 21) ||   // Left vertical stroke
                    (x == 44 && y >= 17 && y <= 21) ||   // Right vertical stroke
                    (x == 43 && y == 18) || (x == 43 && y == 19) || (x == 43 && y == 20)) // Diagonal stroke
                    oled_data <= 16'b11111_111111_11111;
                    
                // --- "C" ---
                if ((x == 46 && y >= 17 && y <= 21) ||   // Left vertical stroke
                    (x >= 46 && x <= 48 && y == 17) ||   // Top stroke
                    (x >= 46 && x <= 48 && y == 21))     // Bottom stroke
                    oled_data <= 16'b11111_111111_11111;
                    
                // --- "T" ---
                if ((x >= 50 && x <= 52 && y == 17) ||   // Top stroke
                    (x == 51 && y >= 17 && y <= 21))     // Vertical stroke
                    oled_data <= 16'b11111_111111_11111;
                    
                // --- "I" ---
                if ((x == 55 && y >= 17 && y <= 21))     // Vertical stroke
                    oled_data <= 16'b11111_111111_11111;
                   
                // --- "O" ---
                if ((x == 58 && y >= 17 && y <= 21) ||   // Left vertical stroke
                    (x == 60 && y >= 17 && y <= 21) ||   // Right vertical stroke
                    (x >= 58 && x <= 60 && y == 17) ||   // Top stroke
                    (x >= 58 && x <= 60 && y == 21))     // Bottom stroke
                    oled_data <= 16'b11111_111111_11111;
                    
                // --- "N" ---
                if ((x == 62 && y >= 17 && y <= 21) ||   // Left vertical stroke
                    (x == 64 && y >= 17 && y <= 21) ||   // Right vertical stroke
                    (x == 63 && y == 18) || (x == 63 && y == 19) || (x == 63 && y == 20)) // Diagonal stroke
                    oled_data <= 16'b11111_111111_11111;

            end
        end
            
        // Arithmetic button
        if ((y >= 26 && y <= 35) && (x >= 30 && x <= 70)) begin 
            if ((btnC || (debounced && !mouse_left_prev &&curr_x >= 30 && curr_x <= 68 && curr_y >= 26 && curr_y <= 35)) && cursor_row == 1) begin
                oled_data <= 16'b00000_111111_00000; // Green when selected   
            end
            else begin
        // Draw borders first
            if ((x >= 30 && x <= 68 && y == 26) || (x >= 30 && x <= 68 && y == 35))
                    oled_data <= 16'b11111_111111_11111;
                if ((y >= 26 && y <= 35 && x == 30) || (y >= 26 && y <= 35 && x == 68))
                    oled_data <= 16'b11111_111111_11111;                
                    
                // --- "A" ---
                if ((x == 32 && y >= 28 && y <= 32) ||   // Left vertical stroke
                    (x == 34 && y >= 28 && y <= 32) ||   // Right vertical stroke
                    (x >= 32 && x <= 34 && y == 28) ||   // Top stroke
                    (x >= 32 && x <= 34 && y == 30))     // Middle stroke
                    oled_data <= 16'b11111_111111_11111;
                        
                // --- "R" ---
                if ((x == 36 && y >= 28 && y <= 32) ||   // Left vertical stroke
                    (x >= 36 && x <= 38 && y == 28) ||   // Top stroke
                    (x >= 36 && x <= 38 && y == 30) ||   // Middle stroke
                    (x == 38 && y >= 28 && y <= 30) ||   // Right top
                    (x == 37 && y == 31) ||              // Diagonal
                    (x == 38 && y == 32))                // Bottom right
                    oled_data <= 16'b11111_111111_11111;
                    
                // --- "I" ---
                if ((x == 40 && y >= 28 && y <= 32))     // Vertical stroke
                    oled_data <= 16'b11111_111111_11111;
                    
                // --- "T" ---
                if ((x >= 42 && x <= 44 && y == 28) ||   // Top stroke
                    (x == 43 && y >= 28 && y <= 32))     // Vertical stroke
                    oled_data <= 16'b11111_111111_11111;
                    
                // --- "H" ---
                if ((x == 46 && y >= 28 && y <= 32) ||   // Left vertical stroke
                    (x == 48 && y >= 28 && y <= 32) ||   // Right vertical stroke
                    (x >= 46 && x <= 48 && y == 30))     // Middle stroke
                    oled_data <= 16'b11111_111111_11111;
                    
                // --- "M" ---
                if ((x == 50 && y >= 28 && y <= 32) ||   // Left vertical stroke
                    (x == 52 && y >= 28 && y <= 32) ||   // Right vertical stroke
                    (x == 51 && y == 29) ||              // Middle V
                    (x == 51 && y == 30))
                    oled_data <= 16'b11111_111111_11111;
                    
                // --- "E" ---
                if ((x == 54 && y >= 28 && y <= 32) ||   // Left vertical stroke
                    (x >= 54 && x <= 56 && y == 28) ||   // Top stroke
                    (x >= 54 && x <= 56 && y == 30) ||   // Middle stroke
                    (x >= 54 && x <= 56 && y == 32))     // Bottom stroke
                    oled_data <= 16'b11111_111111_11111;
                    
                // --- "T" ---
                if ((x >= 58 && x <= 60 && y == 28) ||   // Top stroke
                    (x == 59 && y >= 28 && y <= 32))     // Vertical stroke
                    oled_data <= 16'b11111_111111_11111;
                    
                // --- "I" ---
                if ((x == 62 && y >= 28 && y <= 32))     // Vertical stroke
                    oled_data <= 16'b11111_111111_11111;
                    
                // --- "C" ---
                if ((x == 64 && y >= 28 && y <= 32) ||   // Left vertical stroke
                    (x >= 64 && x <= 66 && y == 28) ||   // Top stroke
                    (x >= 64 && x <= 66 && y == 32))     // Bottom stroke
                    oled_data <= 16'b11111_111111_11111;

            end
        end
            
        // Arrow indicating user selection position
        if (x >= 28 && x <= 30) begin
            if (cursor_row == 0) begin
                if (y >= 19 && y <= 21 && (x == 28 || x == 29))
                    oled_data <= 16'b11111_111111_11111;
                if (y == 20 && x == 30)
                    oled_data <= 16'b11111_111111_11111;
            end
        end
            
        if (x >= 26 && x <= 28) begin
            if (cursor_row == 1) begin
                if (y >= 30 && y <= 32 && (x == 26 || x == 27))
                    oled_data <= 16'b11111_111111_11111;
                if (y == 31 && x == 28)
                    oled_data <= 16'b11111_111111_11111;
            end
        end
        mouse_left_prev <= debounced;
    end
endmodule
