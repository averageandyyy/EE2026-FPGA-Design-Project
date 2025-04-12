`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 10:03:14
// Design Name: 
// Module Name: phase_two_menu_controller
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
This module handles both the cursor logic and state transition logic
to move in and out of phase_three
*/
module phase_two_menu_controller(
    input clock,
    input btnU, btnD, btnC, btnL,
    output reg cursor_row,
    output reg is_phase_three,
    output reg is_arithmetic_mode,
    input is_getting_coefficients,
    input is_phase_two,
    input back_switch,
    input [6:0] curr_x, curr_y,
    input mouse_left,
    input middle,
    input use_mouse,
    input clk_100MHz,
    input clk_6p25MHz
    );
        //debouncing for left mouse button
     parameter DEBOUNCE_DELAY = 2000000;
     reg [21:0] counter;    // Counter for debounce delay (needs enough bits)
     reg debounced;         // Stores the debounced state
     
     reg mouse_left_prev;
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

    initial begin
        cursor_row <= 0;
        is_phase_three <= 0;
        is_arithmetic_mode <= 0;
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

    always @ (posedge clock) begin
        // Decrement debounce counters if active
        if (debounce_U > 0) debounce_U <= debounce_U - 1;
        if (debounce_D > 0) debounce_D <= debounce_D - 1;
        if (debounce_L > 0) debounce_L <= debounce_L - 1;
        if (debounce_C > 0) debounce_C <= debounce_C - 1;

        case (current_state)
            // Only listen iff phase_two
            START: begin
                if (is_phase_two && !is_phase_three) begin
                    if (use_mouse && curr_x >= 32 && curr_x <= 66 & curr_y >= 15 && curr_y <= 24) begin
                        cursor_row <= 0;
                        if ((use_mouse && debounced && !mouse_left_prev)) begin
                            if (cursor_row) begin
                                is_phase_three <= 1;
                                is_arithmetic_mode <= 1;
                            end
                            else if (!cursor_row) begin
                                is_phase_three <= 1;
                            end
                            // Transition to a state that allows phase_two to be false
                            current_state <= WAIT_TO_GO_BACK;
                        end
                    end
                        
                    else if (use_mouse && curr_x >= 30 && curr_x <= 68 && curr_y >= 26 && curr_y <= 35) begin
                        cursor_row <= 1;
                        if ((use_mouse && debounced && !mouse_left_prev)) begin
                            if (cursor_row) begin
                                is_phase_three <= 1;
                                is_arithmetic_mode <= 1;
                            end
                            else if (!cursor_row) begin
                                is_phase_three <= 1;
                            end
                            // Transition to a state that allows phase_two to be false
                            current_state <= WAIT_TO_GO_BACK;
                        end

                    end
                        
                    // Up Down movement
                    if (btnU && !prev_btnU && debounce_U == 0) begin
                        cursor_row <= ~cursor_row;
                        debounce_U <= 200;
                    end

                    if (btnD && !prev_btnD && debounce_D == 0) begin
                        cursor_row <= ~cursor_row;
                        debounce_D <= 200;
                    end

                    // Arithmetic Selection or Function Selection
                    // Only supports transition to phase two i.e. click start
                    if (btnC && !prev_btnC && debounce_C == 0 || (use_mouse && debounced && !mouse_left_prev)) begin
                        if (cursor_row) begin
                            is_phase_three <= 1;
                            is_arithmetic_mode <= 1;
                        end
                        else if (!cursor_row) begin
                            is_phase_three <= 1;
                        end
                        // Transition to a state that allows phase_two to be false
                        current_state <= WAIT_TO_GO_BACK;
                        debounce_C <= 200;
                    end
                end
            end

            WAIT_TO_GO_BACK: begin
                // Go back iff at phase_three, we are either in arithmetic or obtaining coefficients
                if (is_phase_three && back_switch && (btnL || (use_mouse && debounced_middle && !mouse_middle_prev))  && (is_arithmetic_mode || is_getting_coefficients)) begin
                    is_arithmetic_mode <= 0;
                    is_phase_three <= 0;
                    cursor_row <= 0;
                    current_state <= START;
                end
            end
        endcase

        prev_btnU <= btnU;
        prev_btnC <= btnC;
        prev_btnD <= btnD; 
        mouse_left_prev <= debounced;
        
    end
endmodule
