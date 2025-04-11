`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 09:22:20
// Design Name: 
// Module Name: phase_one_menu_display
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
This module is responsible for rendering the PHASE ONE menu,
showing user SYStor, START and HELP

Listens on phase_one_menu_controller for cursor_row
*/

module phase_one_menu_display(
    input clock,
    input mouse_left,
    input clk_100MHz,
    input [12:0] pixel_index,
    output reg [15:0] oled_data,
    input cursor_row, // Only has 2 rows
    input btnC,
    input use_mouse,
    input [11:0] xpos, ypos,
    input middle
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
         wire [6:0] curr_x, curr_y;
     
     //get current coordinates of the mouse
    mouse_coordinate_extractor coord_extr(
         clock, //6p25MHz clock
         xpos,    // 12-bit mouse x position
         ypos,    // 12-bit mouse y position
         curr_x, curr_y);
     //end of getting current coordinates of the mouse


    // Drawing the menu
    always @ (posedge clock) begin
        // WTFUCK idk why this was needed to render the stuff below
        oled_data <= 16'b0;
       
        if ((y >= 5 && y <= 11) && (x >= 28 && x <= 68)) begin
            // --- "S" ---
            if ((x >= 28 && x <= 33 && y == 5) || 
                (x == 28 && y >= 5 && y <= 8) || 
                (x >= 28 && x <= 33 && y == 8) || 
                (x == 33 && y >= 8 && y <= 11) || 
                (x >= 28 && x <= 33 && y == 11)) 
                oled_data <= 16'b11111_111111_11111;
            
            // --- "Y" ---
            if ((x == 36 && y >= 5 && y <= 7) || 
                (x == 40 && y >= 5 && y <= 7) || 
                (x >= 36 && x <= 40 && y == 7) || 
                (x == 38 && y >= 7 && y <= 11)) 
                oled_data <= 16'b11111_111111_11111;
            
            // --- "S" ---
            if ((x >= 43 && x <= 48 && y == 5) || 
                (x == 43 && y >= 5 && y <= 8) || 
                (x >= 43 && x <= 48 && y == 8) || 
                (x == 48 && y >= 8 && y <= 11) || 
                (x >= 43 && x <= 48 && y == 11)) 
                oled_data <= 16'b11111_111111_11111;
            
            // --- "t" ---
            if ((x >= 51 && x <= 55 && y == 7) ||  
                (x == 53 && y >= 5 && y <= 11))    
                oled_data <= 16'b11111_111111_11111;
            
            // --- "o" ---
            if ((x >= 58 && x <= 62 && y == 7) || 
                (x == 58 && y >= 7 && y <= 11) || 
                (x == 62 && y >= 7 && y <= 11) || 
                (x >= 58 && x <= 62 && y == 11)) 
                oled_data <= 16'b11111_111111_11111;
            
            // --- "r" ---
            if ((x == 65 && y >= 7 && y <= 11) || 
                (x >= 65 && x <= 68 && y == 7)) 
                oled_data <= 16'b11111_111111_11111;
        end
            
        // start "button"
        // the dimensions for the characters are: 3 bits wide, 5 bits tall
        if ((y >= 34 && y <= 44) && (x >= 35 && x <= 60)) begin 
            if ((btnC || (use_mouse && debounced && !mouse_left_prev && curr_x >= 35 && curr_x <= 60 && curr_y >= 34 && curr_y <= 44)) && cursor_row == 0) begin
                oled_data <= 16'b00000_111111_00000; // Green when selected
            end else begin
                // Draw the borders first
                //draw the horizontal borders
                if ((x >= 35 && x <= 60 && y == 34) || (x >= 35 && x <= 60 && y == 44))
                    oled_data <= 16'b11111_111111_11111;
                //draw the vertical borders
                if ((y >= 34 && y <= 44 && x == 35) || (y >= 34 && y <= 44 && x == 60))
                    oled_data <= 16'b11111_111111_11111;
                
                // Draw start
                // --- "s" ---
                if ((x >= 37 && x <= 39 && y == 36) ||  // Top stroke
                    (x == 37 && y >= 36 && y <= 39) ||  // Left vertical
                    (x >= 37 && x <= 39 && y == 39) ||  // Middle stroke
                    (x == 39 && y >= 39 && y <= 41) ||  // Right vertical
                    (x >= 37 && x <= 39 && y == 41))    // Bottom stroke
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "t" ---
                if ((x >= 41 && x <= 44 && y == 36) ||  // Horizontal top bar
                    (x == 42 && y >= 36 && y <= 41))    // Vertical stroke
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "a" ---
                if ((x >= 46 && x <= 49 && y == 36) ||  // Top arc
                    (x == 46 && y >= 36 && y <= 41) ||  // Left vertical
                    (x == 49 && y >= 36 && y <= 41) ||  // Right vertical
                    (x >= 46 && x <= 49 && y == 38))    // Middle stroke
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "r" ---
                if ((x == 51 && y >= 36 && y <= 41) ||  // Vertical stroke
                    (x >= 51 && x <= 54 && y == 36) ||  // Top stroke
                    (x == 54 && y >= 36 && y <= 38) ||  // Right Vertical stroke
                    (y == 38 && x >= 51 && x <= 54) ||  // Horizontal stroke
                    (x == 54 && y >= 40 && y <= 41) ||  // Vertical part of r
                    (x == 53 && y == 39))
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "t" (again) ---
                if ((x >= 56 && x <= 59 && y == 36) ||  // Horizontal top bar
                    (x == 57 && y >= 36 && y <= 41))    // Vertical stroke
                    oled_data <= 16'b11111_111111_11111;
            end
        
        end
            
        // help "button"
        // the dimensions for the characters are: 3 bits wide, 5 bits tall
        if ((y >= 46 && y <= 56) && (x >= 35 && x <= 60)) begin
            if ((btnC || (use_mouse && debounced && !mouse_left_prev && curr_x >= 35 && curr_x <= 60 && curr_y <= 56 && curr_y >= 46))&& cursor_row == 1) begin
                oled_data <= 16'b00000_111111_00000; // Green when selected
            end else begin
            // Draw the borders first
                if ((x >= 35 && x <= 60 && y == 46) || (x >= 35 && x <= 60 && y == 56))
                    oled_data <= 16'b11111_111111_11111;
                if ((y >= 46 && y <= 56 && x == 35) || (y >= 46 && y <= 56 && x == 60))
                    oled_data <= 16'b11111_111111_11111;
                    
            // Draw Help
                // --- "H" ---
                if (((x == 39 || x == 41) && y >= 48 && y <= 53) ||   // Vertical bars
                    (x >= 39 && x <= 41 && y == 50))    // Horizontal bar
                    oled_data <= 16'b11111_111111_11111;
                        
                // --- "E" ---
                if ((x == 43 && y >= 48 && y <= 53) ||  // Left vertical bar
                    (x >= 43 && x <= 46 && (y == 48 || y == 50 || y == 53))) // Top, middle, and bottom horizontal bars
                    oled_data <= 16'b11111_111111_11111;
        
                // --- "L" ---
                if ((x == 48 && y >= 48 && y <= 53) ||  // Vertical stroke
                    (x >= 48 && x <= 51 && y == 53))    // Bottom stroke
                    oled_data <= 16'b11111_111111_11111;
        
                // --- "P" ---
                if ((x == 53 && y >= 48 && y <= 53) ||  // Vertical stroke
                    (x >= 53 && x <= 56 && y == 48) ||  // Top stroke
                    (x == 56 && y >= 48 && y <= 50) ||  // Right vertical stroke
                    (x >= 53 && x <= 56 && y == 50))    // Middle stroke
                    oled_data <= 16'b11111_111111_11111;
            end
        end
            
        // Arrow indicating user selection position
        if (x >= 31 && x <= 34) begin
            if (cursor_row == 0) begin
                if (y >= 38 && y <= 40 && (x == 31 || x == 32))
                    oled_data <= 16'b11111_111111_11111;
                if (y == 39 && x == 33)
                    oled_data <= 16'b11111_111111_11111;
            end
            else if (cursor_row == 1) begin
                if (y >= 50 && y <= 52 && (x == 31 || x == 32))
                    oled_data <= 16'b11111_111111_11111;
                if (y == 51 && x == 33)
                    oled_data <= 16'b11111_111111_11111;
            end
        end
        mouse_left_prev <= debounced;
    end
endmodule
