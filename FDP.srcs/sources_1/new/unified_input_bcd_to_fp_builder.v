`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2025 09:36:24
// Design Name: 
// Module Name: unified_input_bcd_to_fp_builder
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
The intention behind this module is to have a singular input builder module
that can be reused/instantiated across any module that requires dynamic user input via a keypad.

enable_negative has been introduced for polynomial.
enable_backspace has been introduced for arithmetic.

Most significant change has been the migration of the conversion logic from a
function to a FSM, which ideally, should also encourage lower resource utilization.

Should work with arithmetic_backend and polynomial_table_cursor_controller.
*/

module unified_input_bcd_to_fp_builder(
    input clk,
    input keypad_btn_pressed,
    input [3:0] selected_keypad_value,

    // This flag replaces is_operand_mode and is_table_input_mode
    input is_active_mode,
    input reset,

    // Module specific support
    input enable_negative,
    input enable_backspace,

    output reg has_decimal = 0,
    output reg has_negative = 0,
    output reg [3:0] input_index = 0,
    output reg signed [31:0] fp_value = 0,
    output reg [31:0] bcd_value = 0,
    output reg input_complete = 0,
    output reg [3:0] decimal_pos = 4'hF
    );

    // Variables to store 8 BCD digits
    reg [3:0] bcd_digits[0:7];
    reg [3:0] valid_digits = 0;

    // Constants (Inputs)
    parameter CHECKMARK = 4'd12;
    parameter DECIMAL = 4'd10;
    // This is either BACKSPACE or NEGATIVE based on feature flags
    parameter SPECIAL_KEY = 4'd11;   

    // Conversion State Machine (inspired by fp_to_string_sequential)
    localparam IDLE = 0;
    localparam PROCESS_INTEGER = 1;
    localparam PROCESS_FRACTION = 2;
    localparam APPLY_SIGN = 3;
    localparam CONVERSION_DONE = 4;

    reg [2:0] conv_state = IDLE;
    reg [31:0] integer_part, fractional_part;
    reg [31:0] power_of_ten;
    reg [3:0] digit_idx;

    localparam MAX_Q16_INT = 32767;

    integer i;

    // Loop to update packed BCD value from individual digits
    always @ (*) begin
        bcd_value = {
            bcd_digits[7], bcd_digits[6], bcd_digits[5], bcd_digits[4],
            bcd_digits[3], bcd_digits[2], bcd_digits[1], bcd_digits[0]
        };
    end

    always @(posedge clk) begin
        // Default: Reset input_complete flag
        input_complete <= 0;
        
        // If reset or not in active input mode, clear all values
        if (reset || !is_active_mode) begin
            input_index <= 0;
            has_decimal <= 0;
            has_negative <= 0;
            decimal_pos <= 4'hF;
            valid_digits <= 0;
            
            // Only reset the value on system reset, not on mode transitions. Across modes, the logic has made it such that we want
            // to retain the last inputted value!
            if (reset) begin
                fp_value <= 0;
            end
            
            // Clear digit buffer
            for (i = 0; i < 8; i = i + 1) begin
                bcd_digits[i] <= 0;
            end
            
            // Reset conversion state
            conv_state <= IDLE;
        end
        else begin
            // In active mode, process button presses
            if (keypad_btn_pressed) begin
                case (selected_keypad_value)
                    CHECKMARK: begin
                        if (valid_digits > 0 || (valid_digits == 0 && has_decimal)) begin
                            // Start the conversion state machine
                            conv_state <= PROCESS_INTEGER;
                            integer_part <= 0;
                            fractional_part <= 0;
                            digit_idx <= 0;
                        end
                    end
                    
                    DECIMAL: begin
                        if (!has_decimal && input_index < 8) begin
                            has_decimal <= 1;
                            decimal_pos <= input_index;
                            input_index <= input_index + 1;
                        end
                    end
                    
                    SPECIAL_KEY: begin
                        if (enable_backspace) begin
                            // Backspace functionality
                            if (input_index > 0) begin
                                input_index <= input_index - 1;
                                
                                // Check if removing decimal point
                                if (has_decimal) begin
                                    has_decimal <= 0;
                                    decimal_pos <= 4'hF;
                                end 
                                // Digit removal
                                else if (valid_digits > 0) begin
                                    valid_digits <= valid_digits - 1;
                                    bcd_digits[valid_digits - 1] <= 0;
                                end
                            end
                        end
                        else if (enable_negative) begin
                            // Negative sign functionality (only allow at beginning of input)
                            if (input_index == 0 && !has_negative) begin
                                has_negative <= 1;
                                input_index <= input_index + 1;
                            end
                        end
                    end
                    
                    default: begin
                        // Process regular digits (0-9)
                        if (input_index < 8 && valid_digits < 8) begin
                            bcd_digits[valid_digits] <= selected_keypad_value;
                            input_index <= input_index + 1;
                            valid_digits <= valid_digits + 1;
                        end
                    end
                endcase
            end
            
            // Conversion state machine (runs independently of button presses)
            case (conv_state)
                IDLE: begin
                    // Waiting for checkmark press
                end
                
                PROCESS_INTEGER: begin
                    if (decimal_pos == 4'hF) begin
                        // No decimal point - process all digits as integer
                        if (digit_idx < valid_digits) begin
                            integer_part <= (integer_part * 10) + bcd_digits[digit_idx];
                            digit_idx <= digit_idx + 1;
                        end
                        else begin
                            // Done processing integer part, skip to sign application
                            conv_state <= APPLY_SIGN;
                        end
                    end
                    else begin
                        // Process integer part (before decimal)
                        if (has_negative) begin
                            if (digit_idx < decimal_pos - 1) begin
                                integer_part <= (integer_part * 10) + bcd_digits[digit_idx];
                                digit_idx <= digit_idx + 1;
                            end
                            else begin
                                // Finished integer part, start fractional
                                conv_state <= PROCESS_FRACTION;
                                // digit_idx <= decimal_pos;
                                power_of_ten <= 1;
                            end
                        end
                        else begin
                            if (digit_idx < decimal_pos) begin
                                integer_part <= (integer_part * 10) + bcd_digits[digit_idx];
                                digit_idx <= digit_idx + 1;
                            end
                            else begin
                                // Finished integer part, start fractional
                                conv_state <= PROCESS_FRACTION;
                                digit_idx <= decimal_pos;
                                power_of_ten <= 1;
                            end
                        end
                    end
                end
                
                PROCESS_FRACTION: begin
                    if (digit_idx < valid_digits) begin
                        power_of_ten = power_of_ten * 10;
                        fractional_part <= fractional_part + 
                                          (bcd_digits[digit_idx] * 65536) / power_of_ten;
                        digit_idx <= digit_idx + 1;
                    end
                    else begin
                        conv_state <= APPLY_SIGN;
                    end
                end
                
                APPLY_SIGN: begin
                    // Clamp to maximum value
                    if (integer_part > MAX_Q16_INT) begin
                        integer_part = MAX_Q16_INT;
                    end

                    // Combine integer and fractional parts
                    fp_value <= (integer_part << 16) + fractional_part;
                    
                    // Apply negative sign if needed
                    if (has_negative) begin
                        fp_value <= -((integer_part << 16) + fractional_part);
                    end
                    
                    conv_state <= CONVERSION_DONE;
                end
                
                CONVERSION_DONE: begin
                    input_complete <= 1;
                    conv_state <= IDLE;
                end
            endcase
        end
    end

endmodule
