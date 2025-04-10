`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2025 13:08:09
// Design Name: 
// Module Name: integral_cursor_controller
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


module integral_cursor_controller(
    input clk,
    input clk_6p25MHz,
    input clk_100MHz,
    input reset,
    input btnC,
    input btnU,
    input btnD,
    input btnL,
    input btnR,
    input [11:0] xpos,
    input [11:0] ypos,
    input mouse_left,
    input is_integral_mode,
    input is_integral_input_mode,
    output reg [1:0] cursor_row = 0,
    output reg [2:0] cursor_col = 0,
    output reg keypad_btn_pressed = 0,
    output reg [3:0] keypad_selected_value = 0
    );

    // Previous button states for debouncing
    reg prev_btnC = 0;
    reg prev_btnU = 0;
    reg prev_btnD = 0;
    reg prev_btnL = 0;
    reg prev_btnR = 0;
    
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
        wire [6:0] mouse_xpos, mouse_ypos;
 
 //get current coordinates of the mouse
    mouse_coordinate_extractor coord_extr(
     clk_6p25MHz, //6p25MHz clock
     xpos,    // 12-bit mouse x position
     ypos,    // 12-bit mouse y position
     mouse_xpos, mouse_ypos);
 //end of getting current coordinates of the mouse


    // Debouncing counters
    reg [7:0] debounce_C = 0;
    reg [7:0] debounce_U = 0;
    reg [7:0] debounce_D = 0;
    reg [7:0] debounce_L = 0;
    reg [7:0] debounce_R = 0;

    reg [8:0] count = 500;

    // Flag to track if on the checkmark
    wire on_checkmark = (cursor_col == 3'd3);

    // Button handling loop
    always @ (posedge clk) begin
        if (reset || !is_integral_mode) begin
            // Reset all state variables to initial values
            cursor_row <= 0;
            cursor_col <= 0;
            keypad_btn_pressed <= 0;
            keypad_selected_value <= 0;
            
            // Reset debounce counters and button states
            prev_btnC <= 0;
            prev_btnU <= 0;
            prev_btnD <= 0;
            prev_btnL <= 0;
            prev_btnR <= 0;
            debounce_C <= 0;
            debounce_U <= 0;
            debounce_D <= 0;
            debounce_L <= 0;
            debounce_R <= 0;
            count <= 500;
        end
        else if (is_integral_input_mode) begin
            if (count == 0) begin
                // Reset button pressed signal each cycle
                keypad_btn_pressed <= 0;
            
                // Decrement debounce counters if active
                if (debounce_U > 0) debounce_U <= debounce_U - 1;
                if (debounce_D > 0) debounce_D <= debounce_D - 1;
                if (debounce_L > 0) debounce_L <= debounce_L - 1;
                if (debounce_R > 0) debounce_R <= debounce_R - 1;
                if (debounce_C > 0) debounce_C <= debounce_C - 1;

                // Up button processing
                if (btnU && !prev_btnU && debounce_U == 0) begin
                    if (cursor_row > 0 && !on_checkmark) begin
                        cursor_row <= cursor_row - 1;
                    end
                    debounce_U <= 200;
                end
                
                if (mouse_xpos >= 0 && mouse_xpos <= 23 && mouse_ypos >= 0 && mouse_ypos <= 15) begin // for 7
                    cursor_row <= 0;
                    cursor_col <= 0; 
                end
                else if (mouse_xpos >= 24 && mouse_xpos <= 47 && mouse_ypos >= 0 && mouse_ypos <= 15) begin //for 8
                    cursor_row <= 0;
                    cursor_col <= 1;
                end
                else if (mouse_xpos >= 48 && mouse_xpos <= 71 && mouse_ypos >= 0 && mouse_ypos <= 15) begin //for 9
                    cursor_row <= 0; 
                    cursor_col <= 2;
                end
                else if (mouse_xpos >= 0 && mouse_xpos <= 23 && mouse_ypos >= 16 && mouse_ypos <= 31) begin //for 4
                    cursor_row <= 1;
                    cursor_col <= 0;
                end
                else if (mouse_xpos >= 24 && mouse_xpos <= 47 && mouse_ypos >= 16 && mouse_ypos <= 31) begin //for 5
                    cursor_row <= 1;
                    cursor_col <= 1;
                end
                else if (mouse_xpos >= 48 && mouse_xpos <= 71 && mouse_ypos >= 16 && mouse_ypos <= 31) begin //for 6
                    cursor_row <= 1;
                    cursor_col <= 2;
                end
                else if (mouse_xpos >= 0 && mouse_xpos <= 23 && mouse_ypos >= 32 && mouse_ypos <= 47) begin //for 1
                    cursor_row <= 2;
                    cursor_col <= 0;
                end
                else if (mouse_xpos >= 24 && mouse_xpos <= 47 && mouse_ypos >= 32 && mouse_ypos <= 47) begin //for 2
                    cursor_row <= 2;
                    cursor_col <= 1;
                end
                else if (mouse_xpos >= 48 && mouse_xpos <= 71 && mouse_ypos >= 32 && mouse_ypos <= 47) begin //for 3
                    cursor_row <= 2;
                    cursor_col <= 2;
                end
                else if (mouse_xpos >= 0 && mouse_xpos <= 23 && mouse_ypos >= 48 && mouse_ypos <= 63) begin //for 0
                    cursor_row <= 3;
                    cursor_col <= 0;
                end 
                else if (mouse_xpos >= 24 && mouse_xpos <= 47 && mouse_ypos >= 48 && mouse_ypos <= 63) begin //for .
                    cursor_row <= 3;
                    cursor_col <= 1;
                end
                else if (mouse_xpos >= 48 && mouse_xpos <= 71 && mouse_ypos >= 48 && mouse_ypos <= 63) begin //for -
                    cursor_row <= 3;
                    cursor_col <= 2;
                end
                else begin //on equal sign/checkmark
                    cursor_col <= 3'd3;
                end
                    
                    
                
                
                
                // Down
                if (btnD && !prev_btnD && debounce_D == 0) begin
                    if (cursor_row < 3 && !on_checkmark) begin
                        cursor_row <= cursor_row + 1;
                    end
                    debounce_D <= 200;
                end

                // Left
                if (btnL && !prev_btnL && debounce_L == 0) begin
                    if (on_checkmark) begin
                        // Moving left from checkmark goes to the main keypad
                        cursor_col <= 3'd2;
                    end else if (cursor_col > 0) begin
                        cursor_col <= cursor_col - 1;
                    end
                    debounce_L <= 200;
                end

                // Right
                if (btnR && !prev_btnR && debounce_R == 0) begin
                    if (!on_checkmark && cursor_col < 2) begin
                        cursor_col <= cursor_col + 1;
                    end else if (!on_checkmark && cursor_col == 2) begin
                        cursor_col <= 3'd3;  // Go to checkmark column
                    end
                    debounce_R <= 200;
                end

                // Center (Selection)
                if (btnC && !prev_btnC && debounce_C == 0 || (debounced && !mouse_left_prev)) begin
                    keypad_btn_pressed <= 1;

                    if (on_checkmark) begin
                        // Checkmark selected
                        keypad_selected_value <= 4'd12;  // Special value for checkmark

                        // Reset cursor position after submission
                        cursor_col <= 0;
                        cursor_row <= 0;
                    end else begin
                        // Determining selected value based on cursor position in main keypad
                        case(cursor_row)
                            2'd0: keypad_selected_value <= cursor_col + 4'd7; // 7, 8, 9
                            2'd1: keypad_selected_value <= cursor_col + 4'd4; // 4, 5, 6
                            2'd2: keypad_selected_value <= cursor_col + 4'd1; // 1, 2, 3
                            2'd3: begin
                                case(cursor_col)
                                    2'd0: keypad_selected_value <= 4'd0; // 0
                                    2'd1: keypad_selected_value <= 4'd10; // . decimal
                                    2'd2: keypad_selected_value <= 4'd11; // - negative sign (not backspace)
                                endcase
                            end
                        endcase
                    end

                    debounce_C <= 200;
                end

                // Update previous button states
                prev_btnU <= btnU;
                prev_btnD <= btnD;
                prev_btnL <= btnL;
                prev_btnR <= btnR;
                prev_btnC <= btnC;
                mouse_left_prev <= debounced;

            end
            else begin
                count <= count - 1;
            end
        end
    end
endmodule
