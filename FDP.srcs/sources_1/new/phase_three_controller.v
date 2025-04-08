`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2025 13:44:16
// Design Name: 
// Module Name: phase_three_controller
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
This module is responsible for transitioning between GET_COEFFICIENTS, MENU_SELECTION
and SELECTED_FUNCTION, accounting for backwards transitions as well.
*/
module phase_three_controller(
    input clock,
    input btnU, btnD, btnC, btnL, btnR,
    input back_switch,
    input is_phase_three,
    input is_arithmetic_mode,
    output reg is_getting_coefficients = 0,
    output reg [1:0] coeff_state = 0,
    output reg is_menu_selection = 0,
    output reg is_table_selected = 0,
    output reg is_integral_selected = 0,
    output reg cursor_row = 0,
    output reg signed [31:0] coeff_a = 0,
    output reg signed [31:0] coeff_b = 0,
    output reg signed [31:0] coeff_c = 0,
    output reg signed [31:0] coeff_d = 0,
    
    // For keypad and input building interaction
    input input_complete,
    input signed [31:0] fp_value,
    output reg keypad_active = 0
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
    
    // State definitions
    localparam IDLE = 0;
    localparam GET_COEFF_A = 1;
    localparam GET_COEFF_B = 2;
    localparam GET_COEFF_C = 3;
    localparam GET_COEFF_D = 4;
    localparam MENU_SELECTION = 5;
    localparam SELECTED_FUNCTION = 6;
    
    reg [2:0] current_state = IDLE;

    always @(posedge clock) begin
        // Decrement debounce counters if active
        if (debounce_U > 0) debounce_U <= debounce_U - 1;
        if (debounce_D > 0) debounce_D <= debounce_D - 1;
        if (debounce_L > 0) debounce_L <= debounce_L - 1;
        if (debounce_C > 0) debounce_C <= debounce_C - 1;
        
        // Only process when in phase three and NOT in arithmetic mode
        if (is_phase_three && !is_arithmetic_mode) begin
            case (current_state)
                IDLE: begin
                    // Initial state, start getting coefficients
                    is_getting_coefficients <= 1;
                    is_menu_selection <= 0;
                    is_table_selected <= 0;
                    is_integral_selected <= 0;
                    keypad_active <= 1;
                    coeff_state <= 2'b00; // Start with coefficient A
                    current_state <= GET_COEFF_A;
                end
                
                GET_COEFF_A: begin
                    is_getting_coefficients <= 1;
                    coeff_state <= 2'b00;
                    keypad_active <= 1;
                    
                    if (input_complete) begin
                        coeff_a <= fp_value;
                        current_state <= GET_COEFF_B;
                        
                        // Need to reset the input builder!
                        keypad_active <= 0;
                    end
                end
                
                GET_COEFF_B: begin
                    is_getting_coefficients <= 1;
                    coeff_state <= 2'b01;
                    
                    if (!keypad_active) begin
                        keypad_active <= 1;
                    end
                    
                    if (input_complete) begin
                        coeff_b <= fp_value;
                        current_state <= GET_COEFF_C;
                        keypad_active <= 0;
                    end
                end
                
                GET_COEFF_C: begin
                    is_getting_coefficients <= 1;
                    coeff_state <= 2'b10;

                    if (!keypad_active) begin
                        keypad_active <= 1;
                    end
                    
                    if (input_complete) begin
                        coeff_c <= fp_value;
                        current_state <= GET_COEFF_D;
                        keypad_active <= 0;
                    end
                end
                
                GET_COEFF_D: begin
                    is_getting_coefficients <= 1;
                    coeff_state <= 2'b11;

                    if (!keypad_active) begin
                        keypad_active <= 1;
                    end
                    
                    if (input_complete) begin
                        coeff_d <= fp_value;
                        is_getting_coefficients <= 0;
                        is_menu_selection <= 1;
                        keypad_active <= 0;
                        cursor_row <= 0; // Default to TABLE
                        current_state <= MENU_SELECTION;
                    end
                end
                
                MENU_SELECTION: begin
                    is_getting_coefficients <= 0;
                    is_menu_selection <= 1;
                    keypad_active <= 0;
                    
                    // Handle cursor movement
                    if (btnU && !prev_btnU && debounce_U == 0) begin
                        cursor_row <= 0; // TABLE option
                        debounce_U <= 200;
                    end
                    
                    if (btnD && !prev_btnD && debounce_D == 0) begin
                        cursor_row <= 1; // INTG option
                        debounce_D <= 200;
                    end
                    
                    // Handle selection
                    if (btnC && !prev_btnC && debounce_C == 0) begin
                        is_menu_selection <= 0;
                        
                        if (cursor_row == 0) begin
                            is_table_selected <= 1;
                            is_integral_selected <= 0;
                        end else begin
                            is_table_selected <= 0;
                            is_integral_selected <= 1;
                        end
                        
                        current_state <= SELECTED_FUNCTION;
                        debounce_C <= 200;
                    end
                    
                    // Back button - go back to first coefficient
                    if (btnL && !prev_btnL && back_switch && debounce_L == 0) begin
                        is_menu_selection <= 0;
                        is_getting_coefficients <= 1;
                        keypad_active <= 1;
                        current_state <= GET_COEFF_A;
                        debounce_L <= 200;
                    end
                end
                
                SELECTED_FUNCTION: begin
                    // In this state, specific modules take over
                    
                    // Back button - go back to menu
                    if (btnL && !prev_btnL && back_switch && debounce_L == 0) begin
                        is_table_selected <= 0;
                        is_integral_selected <= 0;
                        is_menu_selection <= 1;
                        current_state <= MENU_SELECTION;
                        debounce_L <= 200;
                    end
                end
            endcase
        end
        else begin
            // Reset state when not in phase three or in arithmetic mode
            current_state <= IDLE;
            is_getting_coefficients <= 0;
            is_menu_selection <= 0;
            is_table_selected <= 0;
            is_integral_selected <= 0;
            keypad_active <= 0;
        end
        
        // Update button states
        prev_btnU <= btnU;
        prev_btnD <= btnD;
        prev_btnC <= btnC;
        prev_btnL <= btnL;
    end
endmodule
