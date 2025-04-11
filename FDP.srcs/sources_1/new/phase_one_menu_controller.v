`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 09:32:20
// Design Name: 
// Module Name: phase_one_menu_controller
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
This module handles both the cursor logic and some state transition logic
*/

module phase_one_menu_controller(
    input clk_100MHz,
    input clk_6p25MHz,
    input clock,
    input btnU, btnD, btnC, btnL,
    output reg cursor_row,
    output reg is_phase_two,
    input is_phase_three,
    input back_switch,
    input [11:0] xpos, ypos,
    input use_mouse,
    input mouse_left,
    input middle
    );

    // Previous button states for debouncing
    reg prev_btnC = 0;
    reg prev_btnU = 0;
    reg prev_btnD = 0;
    reg prev_btnL = 0;

    // Debouncing counters
    reg [7:0] debounce_C = 0;
    reg [7:0] debounce_U = 0;
    reg [7:0] debounce_D = 0;
    reg [7:0] debounce_L = 0;
    
    //debouncing for left mouse button
    parameter DEBOUNCE_DELAY = 2000000;
    reg [21:0] counter;    // Counter for debounce delay (needs enough bits)
    reg debounced;         // Stores the debounced state
    
    reg mouse_left_prev;
     //debouncing for middle mouse button
        reg [21:0] middle_counter;    // Counter for debounce delay (needs enough bits)
        reg debounced_middle;         // Stores the debounced state
        initial begin
            middle_counter   = 0;
            debounced_middle = 1'b0;
        end
        always @(posedge clk_100MHz) begin
                if (middle == debounced_middle) 
                    middle_counter <= 0;
                else begin
                    middle_counter <= middle_counter + 1;
                    if (middle_counter >= DEBOUNCE_DELAY) debounced_middle <= middle;
                
                end
        end
        reg mouse_middle_prev;
        initial begin mouse_middle_prev = 1'b0; end
    
    wire [6:0] curr_x, curr_y;
    
    
    //get current coordinates of the mouse
   mouse_coordinate_extractor coord_extr(
        clk_6p25MHz, //6p25MHz clock
        xpos,    // 12-bit mouse x position
        ypos,    // 12-bit mouse y position
        curr_x, curr_y);
    //end of getting current coordinates of the mouse
    
    initial begin
        cursor_row <= 0;
        is_phase_two <= 0;
        mouse_left_prev = 1'b0;
        counter = 0;
        debounced = 1'b0;
    end

    reg current_state = 0;
    localparam START = 0;
    localparam WAIT_TO_GO_BACK = 1;
    always @(posedge clk_100MHz) begin
                 if (mouse_left == debounced) 
                     counter <= 0;
                 else begin
                     counter <= counter + 1;
                     if (counter >= DEBOUNCE_DELAY) debounced <= mouse_left;
                 
                 end
    end
    //end of LMB debouncing

    always @ (posedge clock) begin
        // Decrement debounce counters if active
        if (debounce_U > 0) debounce_U <= debounce_U - 1;
        if (debounce_D > 0) debounce_D <= debounce_D - 1;
        if (debounce_L > 0) debounce_L <= debounce_L - 1;
        if (debounce_C > 0) debounce_C <= debounce_C - 1;

        case (current_state)
            // Handle cursor movement and selection
            START: begin
                if (!is_phase_two) begin
                    // Up Down movement
                    if (use_mouse) begin
                        if (curr_x >= 35 && curr_x <= 60 && curr_y >= 34 && curr_y <= 44) begin
                            cursor_row <= 0;
                            if (debounced && !mouse_left_prev) begin
                                if (!cursor_row) begin
                                    is_phase_two <= 1;
                                    current_state <= WAIT_TO_GO_BACK; end
                            end                            
                        end
                        else if (curr_x >= 35 && curr_x <= 60 && curr_y <= 56 && curr_y >= 46) begin
                            cursor_row <= 1;
                            if (debounced && !mouse_left_prev) begin
                                if (!cursor_row) begin
                                    is_phase_two <= 1;
                                    current_state <= WAIT_TO_GO_BACK; end
                            end
                        end          
                    end
                   
                    if (btnU && !prev_btnU && debounce_U == 0) begin
                        cursor_row <= ~cursor_row;
                        debounce_U <= 200;
                    end

                    if (btnD && !prev_btnD && debounce_D == 0) begin
                        cursor_row <= ~cursor_row;
                        debounce_D <= 200;
                    end

                    // Only supports transition to phase two i.e. click start
                    if (btnC && !prev_btnC && debounce_C == 0) begin
                        if (!cursor_row) begin
                            is_phase_two <= 1;
                            // Transition to a state that allows phase_two to be false
                            current_state <= WAIT_TO_GO_BACK;
                        end
                        debounce_C <= 200;
                    end
                end
            end
            
            WAIT_TO_GO_BACK: begin
                // Check for conditions that flip is_phase_two to false
                // We can only go back iff we are at phase two
                if (is_phase_two && (btnL || (use_mouse && debounced_middle && !mouse_middle_prev)) && back_switch && !is_phase_three) begin
                    is_phase_two <= 0;
                    cursor_row <= 0;
                    current_state <= START;
                end
            end
        endcase

        prev_btnU <= btnU;
        prev_btnC <= btnC;
        prev_btnD <= btnD;
        mouse_left_prev <= debounced;
        mouse_middle_prev <= debounced_middle;
    end
endmodule
