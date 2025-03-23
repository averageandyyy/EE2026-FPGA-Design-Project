`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2025 12:33:12 AM
// Design Name: 
// Module Name: main_menu
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


module main_menu(
    input btnC, btnU, btnD, btnL, btnR, // push-buttons
    input basys_clock,
    input [12:0] pixel_index,
    output reg [6:0]seg = 0, // 7-segment display
    output reg [15:0] oled_data = 0, // OLED output
    output reg [3:0] an = 4'b1111
    );
    
    // 1. Show the main menu screen, which consists of name of product, a user manual, and the start
    // NAME: SYStor
    
    // Generate the 25Mhz signal
    wire my_25mHz_signal;
    wire my_1kHz_signal;
    flexible_clock_divider my_25mHz(.main_clock(basys_clock), .ticks(1), .output_clock(my_25mHz_signal));
    flexible_clock_divider my_1kHz(.main_clock(basys_clock), .ticks(49999), .output_clock(my_1kHz_signal));
    
    // y and x coordinates of the OLED display
    wire [6:0] x;
    wire [6:0] y;
    
    // Get the x and y coordinates.
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
        
    // --------------------------------MAIN MENU PARAMETERS--------------------------------
    // stores the state
    // 0: main menu 
    // 1: start menu 
    // 2: manual menu 
    reg [2:0] state = 0;
    reg [2:0] stateFlag = 0;
    
    // Delay counter for state transition
    reg pressed = 0;
    reg [22:0] delay_counter = 0; 

    // Define delay threshold
    parameter DELAY_CYCLES = 8_000_000;
    
    // stores the arrow state
    // 0: on the start button
    // 1: on the help button
    reg [1:0] mainMenuArrowState = 0;
    //-------------------------------------------------------------------------------------
    // --------------------------------START MENU PARAMETERS-------------------------------
    reg startMenuArrowState = 1'b0;
    //-------------------------------------------------------------------------------------
    // --------------------------------FUNC MENU PARAMETERS--------------------------------
    reg [3:0]functionMenuLocationState = 0;
    reg btnC_flag = 0;
    reg [3:0]coeffCounter = 0;
    reg escape_flag = 0;
    // ------------------------------------------------------------------------------------

    // FUNC display
    parameter [6:0] F = 7'b0001110;
    parameter [6:0] U = 7'b1100011;
    parameter [6:0] N = 7'b0101011;
    parameter [6:0] C = 7'b0100111;
    reg [1:0] displayState = 2'b00;
    
    
    // 7-segment handler
    always @ (posedge my_1kHz_signal)
    begin
        if (state == 2'b11) begin
            if (displayState == 2'b00) begin
                an <= 4'b0111;
                seg <= F;
            end
            else if (displayState == 2'b01) begin
                an <= 4'b1011;
                seg <= U;
            end
            else if (displayState == 2'b10) begin
                an <= 4'b1101;
                seg <= N;
            end
            else if (displayState == 2'b11) begin
                an <= 4'b1110;
                seg <= C;
            end
            displayState <= displayState + 1;
        end 
        else begin
            an <= 4'b1111;
        end
    end

    // Handling the main menu arrow
    always @ (posedge my_25mHz_signal)
    begin
        if (btnD && mainMenuArrowState == 0 && state == 0)
            mainMenuArrowState <= 1;
        if (btnU && mainMenuArrowState == 1 && state == 0)
            mainMenuArrowState <= 0;
    end
    
    // Debouncing for push buttons
    reg [25:0] counterR = 0, counterL = 0, counterU = 0, counterD = 0; 
    reg btnR_flag = 0, btnL_flag = 0, btnU_flag = 0, btnD_flag = 0;
    
    // initialisation
    always @ (posedge my_25mHz_signal)
    begin
        // initialise background
        oled_data <= 16'b00000_000000_00000;
        
        // pressed takes note of when a button is pressed. Whenever a button is pressed, pressed will turn to 1.
        if (pressed == 1) begin
            if (delay_counter < DELAY_CYCLES) begin
                delay_counter <= delay_counter + 1;
            end
            if (delay_counter >= DELAY_CYCLES) begin
                state <= stateFlag;
                delay_counter <= 0; // Reset counter
                pressed <= 0;
            end 
        end
        
        // Main menu
        if (state == 2'b00) begin
            // Write the Program title
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
                    if (btnC && mainMenuArrowState == 0) begin
                        pressed <= 1;
                        stateFlag <= 2'b01;
                        oled_data <= 16'b00000_111111_00000; // Green when selected
                    end else begin
                        // Draw the borders first
                        if ((x >= 35 && x <= 60 && y == 34) || (x >= 35 && x <= 60 && y == 44))
                            oled_data <= 16'b11111_111111_11111;
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
                    if (btnC && mainMenuArrowState == 1) begin
                        pressed <= 1;
                        stateFlag <= 2'b10;
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
                    if (mainMenuArrowState == 0) begin
                        if (y >= 38 && y <= 40 && (x == 31 || x == 32))
                           oled_data <= 16'b11111_111111_11111;
                        if (y == 39 && x == 33)
                           oled_data <= 16'b11111_111111_11111;
                    end
                    if (mainMenuArrowState == 1) begin
                        if (y >= 50 && y <= 52 && (x == 31 || x == 32))
                           oled_data <= 16'b11111_111111_11111;
                        if (y == 51 && x == 33)
                           oled_data <= 16'b11111_111111_11111;
                    end
                end
        end
        
        // Start menu
        if (state == 2'b01) begin
            // If the left button is pressed, return to Main menu
            if (btnL) begin
                pressed <= 1;
                stateFlag <= 0;
            end
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
                if (btnC && startMenuArrowState == 0) begin
                    pressed <= 1;
                    stateFlag <= 2'b11;
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
            
            // Arrow indicating user selection position
            if (x >= 28 && x <= 30) begin
                if (startMenuArrowState == 0) begin
                    if (y >= 19 && y <= 21 && (x == 28 || x == 29))
                       oled_data <= 16'b11111_111111_11111;
                    if (y == 20 && x == 30)
                       oled_data <= 16'b11111_111111_11111;
                end
            end            
        end        
        
        // Help menu (Later implementation)
        if (state == 2'b10) begin
            // If the left button is pressed, return to Main menu
            if (btnL) begin
                pressed <= 1;
                stateFlag <= 0;
            end
            // Write Help at the top
            // Draw help
            if ((y >= 5 && y <= 11)) begin 
                // --- "H" ---
                if (((x == 34 || x == 38) && y >= 5 && y <= 11) ||   // vertical bars
                    (x >= 34 && x <= 38 && y == 8))    // Middle stroke
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "E" ---
                if ((x == 40 && y >= 5 && y <= 11) ||  // Vertical stroke
                    (x >= 40 && x <= 44 && y == 5) ||  // Top stroke
                    (x >= 40 && x <= 44 && y == 8) ||  // Middle stroke
                    (x >= 40 && x <= 44 && y == 11))   // Bottom stroke
                    oled_data <= 16'b11111_111111_11111;
            
                // --- "L" ---
                if ((x == 46 && y >= 5 && y <= 11) ||  // Vertical stroke
                    (x >= 46 && x <= 50 && y == 11))   // Bottom stroke
                    oled_data <= 16'b11111_111111_11111;
            
                // --- "P" ---
                if ((x == 52 && y >= 5 && y <= 11) ||  // Vertical stroke
                    (x >= 52 && x <= 56 && y == 5) ||  // Top stroke
                    (x == 56 && y >= 5 && y <= 8) ||   // Right vertical stroke
                    (x >= 52 && x <= 56 && y == 8))    // Middle stroke
                    oled_data <= 16'b11111_111111_11111;
            end
        end
        
        // Function menu
        if (state == 2'b11) begin
            // If the left button is pressed, return to Start menu
            if (btnL && (functionMenuLocationState == 0 || functionMenuLocationState == 2 || functionMenuLocationState == 4 || functionMenuLocationState == 6) && !btnC_flag) begin
                pressed <= 1;
                stateFlag <= 2'b01;
            end 
            // Display FUNC on the 7-segment display
            // Display "Input Coeffs" on the top of the screen.
            if ((y >= 5 && y <= 11) && (x >= 9 && x <= 87)) begin   
            
                // --- "I" ---
                if (x == 11 && y >= 5 && y <= 11)    
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "n" ---
                if ((x == 13 && y >= 5 && y <= 11) ||  
                    (x == 18 && y >= 5 && y <= 11) || (x == 14 && y == 6) || (x == 15 && y == 7) || (x == 16 && y == 8) || (x == 17 && y == 9))
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "p" ---
                if ((x == 20 && y >= 5 && y <= 11) ||  
                    (x >= 20 && x <= 25 && y == 5) ||  
                    (x >= 20 && x <= 25 && y == 7) || (x == 25 && y <= 7 && y >= 5))
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "u" ---
                if ((x == 27 && y >= 5 && y <= 11) ||   
                    (x == 32 && y >= 5 && y <= 11) ||   
                    (x >= 27 && x <= 32 && y == 11))    
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "t" ---
                if ((x >= 34 && x <= 39 && y == 5) ||  
                    (x == 37 && y >= 5 && y <= 11))     
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "C" ---
                if ((x == 42 && y >= 5 && y <= 11) ||  
                    (x >= 42 && x <= 47 && y == 5) ||  
                    (x >= 42 && x <= 47 && y == 11))    
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "o" ---
                if ((x == 49 && y >= 5 && y <= 11) ||  
                    (x == 54 && y >= 5 && y <= 11) ||  
                    (x >= 49 && x <= 54 && y == 5) ||  
                    (x >= 49 && x <= 54 && y == 11))    
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "e" ---
                if ((x == 56 && y >= 5 && y <= 11) ||  
                    (x >= 56 && x <= 61 && y == 5) ||  
                    (x >= 56 && x <= 61 && y == 8) ||  
                    (x >= 56 && x <= 61 && y == 11))    
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "f" ---
                if ((x == 63 && y >= 5 && y <= 11) ||  
                    (x >= 63 && x <= 68 && y == 5) ||  
                    (x >= 63 && x <= 68 && y == 8))     
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "f" ---
                if ((x == 70 && y >= 5 && y <= 11) ||  
                    (x >= 70 && x <= 75 && y == 5) ||  
                    (x >= 70 && x <= 75 && y == 8))     
                    oled_data <= 16'b11111_111111_11111;
                
                // --- "s" ---
                if ((x >= 77 && x <= 82 && y == 5) ||   
                    (x >= 77 && x <= 82 && y == 8) ||
                    (x == 77 && y <= 8 && y >= 5) || (x == 82 && y <= 11 && y >= 8) ||  
                    (x >= 77 && x <= 82 && y == 11))    
                    oled_data <= 16'b11111_111111_11111;
            end
            
            // Write eqn
            if (x >= 9 && x <= 75) begin  
            
                if ((x == 13 && (y == 19 || y == 21)) ||  
                    (x == 15 && (y == 19 || y == 21)) ||  
                    (x == 14 && y == 20) || (x == 12 && (y == 18 || y == 22)) || (x == 16 && (y == 18 || y == 22)))  
                   oled_data <= 16'b11111_111111_11111;

                if ((x == 19 && (y == 15 || y == 17 || y == 19)) || (x == 20 && (y == 16 || y == 18)))  
                   oled_data <= 16'b11111_111111_11111;
                
                if ((x == 13 && (y == 28 || y == 30)) ||  
                    (x == 15 && (y == 28 || y == 30)) ||  
                    (x == 14 && y == 29) ||  
                    (x == 12 && (y == 27 || y == 31)) ||  
                    (x == 16 && (y == 27 || y == 31)))  
                   oled_data <= 16'b11111_111111_11111;
                   
                if ((x == 19 && (y == 24 || y == 26 || y == 27 || y == 28)) || (x == 20 && (y == 25 || y == 28)))  
                   oled_data <= 16'b11111_111111_11111;
                    
                if ((x == 13 && (y == 37 || y == 39)) ||  
                    (x == 15 && (y == 37 || y == 39)) ||  
                    (x == 14 && y == 38) ||  
                    (x == 12 && (y == 36 || y == 40)) ||  
                    (x == 16 && (y == 36 || y == 40)))  
                   oled_data <= 16'b11111_111111_11111;
                
                if ((y == 46 && x >= 12 && x <= 16) || (y == 50 && x >= 12 && x <= 16) || (x == 12 && y >= 46 && y <= 50))
                   oled_data <= 16'b11111_111111_11111;


            end
            
            // Write boxes
            if (((x >= 26 && x < 33) && (y == 16 || y == 23)) || ((y >= 16 && y < 24) && (x == 26 || x == 32))) begin 
                if (functionMenuLocationState == 0) begin
                        oled_data <= 16'b11111_000001_10001;
                    end else begin
                        oled_data <= 16'b11111_111111_11111;         
                    end
                end
            if (((x >= 38 && x < 45) && (y == 16 || y == 23)) || ((y >= 16 && y < 24) && (x == 38 || x == 44)))  
                if (functionMenuLocationState == 1) begin
                        oled_data <= 16'b11111_000001_10001;
                    end else begin
                        oled_data <= 16'b11111_111111_11111;         
                end
            if (((x >= 26 && x < 33) && (y == 26 || y == 33)) || ((y >= 26 && y < 34) && (x == 26 || x == 32)))  
                if (functionMenuLocationState == 2) begin
                        oled_data <= 16'b11111_000001_10001;
                    end else begin
                        oled_data <= 16'b11111_111111_11111;         
                end
            if (((x >= 38 && x < 45) && (y == 26 || y == 33)) || ((y >= 26 && y < 34) && (x == 38 || x == 44)))  
                if (functionMenuLocationState == 3) begin
                        oled_data <= 16'b11111_000001_10001;
                    end else begin
                        oled_data <= 16'b11111_111111_11111;         
                end
            if (((x >= 26 && x < 33) && (y == 36 || y == 43)) || ((y >= 36 && y < 44) && (x == 26 || x == 32)))  
                if (functionMenuLocationState == 4) begin
                        oled_data <= 16'b11111_000001_10001;
                    end else begin
                        oled_data <= 16'b11111_111111_11111;         
                end
            if (((x >= 38 && x < 45) && (y == 36 || y == 43)) || ((y >= 36 && y < 44) && (x == 38 || x == 44)))  
                if (functionMenuLocationState == 5) begin
                    oled_data <= 16'b11111_000001_10001;
                end else begin
                    oled_data <= 16'b11111_111111_11111;         
            end
            if (((x >= 26 && x < 33) && (y == 46 || y == 53)) || ((y >= 46 && y < 54) && (x == 26 || x == 32)))  
                if (functionMenuLocationState == 6) begin
                    oled_data <= 16'b11111_000001_10001;
                end else begin
                    oled_data <= 16'b11111_111111_11111;         
            end
            if (((x >= 38 && x < 45) && (y == 46 || y == 53)) || ((y >= 46 && y < 54) && (x == 38 || x == 44)))  
                if (functionMenuLocationState == 7) begin
                    oled_data <= 16'b11111_000001_10001;
                end else begin
                    oled_data <= 16'b11111_111111_11111;         
            end
            
            if (btnR && !btnC_flag) begin
                // set flag
                btnR_flag <= 1;
            end                     
            // Register button press Right button:
            if (btnR_flag) begin
                if (counterR < 24'hFEFFFF) begin
                    counterR <= counterR + 1;
                end else begin           
                    if (functionMenuLocationState == 0 || functionMenuLocationState == 2 || functionMenuLocationState == 4 || functionMenuLocationState == 6) begin
                        functionMenuLocationState <= functionMenuLocationState + 1;
                    end
                    // Reset parameters
                    counterR <= 0;
                    btnR_flag <= 0;
                end
            end
            
            if (btnL && !btnC_flag) begin
                // set flag
                btnL_flag <= 1;
            end              
            if (btnL_flag) begin
                if (counterL < 24'hFEFFFF) begin
                    counterL <= counterL + 1;
                end else begin             
                if (functionMenuLocationState == 1 || functionMenuLocationState == 3 || functionMenuLocationState == 5 || functionMenuLocationState == 7) begin
                        functionMenuLocationState <= functionMenuLocationState - 1;
                    end
                    // Reset parameters
                    counterL <= 0;
                    btnL_flag <= 0;
                end
            end
    
    
            if (btnU && !btnC_flag) begin
                btnU_flag <= 1;
            end
            if (btnU_flag) begin
                if (counterU < 24'hFEFFFF) begin
                    counterU <= counterU + 1;
                end else begin                 
                    if (!(functionMenuLocationState == 0 || functionMenuLocationState == 1)) begin
                        functionMenuLocationState <= functionMenuLocationState - 2;
                    end
                    counterU <= 0;
                    btnU_flag <= 0;
                end
            end


            if (btnD && !btnC_flag) begin
                btnD_flag <= 1;
            end
            if (btnD_flag) begin
               if (counterD < 24'hFEFFFF) begin
                   counterD <= counterD + 1;
               end else begin
                   if (!(functionMenuLocationState == 6 || functionMenuLocationState == 7)) begin
                        functionMenuLocationState <= functionMenuLocationState + 2;
                   end
                   counterD <= 0;
                   btnD_flag <= 0;
               end
            end
            
            // Write decimal point
            if (x == 35 && (y == 23 || y == 33 || y == 43 || y == 53))
                oled_data <= 16'b11111_111111_11111;
                
            if (btnC) begin
               btnC_flag <= 1; 
            end
            if (btnC_flag) begin
 
                if (functionMenuLocationState == 0) begin
                    
                end
                if (functionMenuLocationState == 1) begin
                    
                end
                if (functionMenuLocationState == 2) begin
                                    
                end
                if (functionMenuLocationState == 3) begin
                                    
                end
                if (functionMenuLocationState == 4) begin
                                    
                end                
                if (functionMenuLocationState == 5) begin
                                    
                end
                if (functionMenuLocationState == 6) begin
                                    
                end                
                if (functionMenuLocationState == 7) begin
                                    
                end
                
                if (btnL) begin
                    escape_flag <= 1;
                end                                      
                if (escape_flag) begin
                    if (counterL < 24'hFEFFFF) begin
                        counterL <= counterL + 1;
                    end else begin             
                        // Reset parameters
                        counterL <= 0;
                        escape_flag <= 0;
                        // escape
                        btnC_flag <= 0;
                    end
                end
            end
        end
    end




endmodule
