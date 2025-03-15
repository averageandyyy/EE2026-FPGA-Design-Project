`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2025 09:46:57
// Design Name: 
// Module Name: input_bcd_to_fp_builder
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


module input_bcd_to_fp_builder(
    input clk,
    input keypad_btn_pressed,
    input [3:0]selected_keypad_value,
    input is_operand_mode,
    input reset,
    output reg has_decimal = 0,
    output reg [63:0]input_buffer,
    output reg [3:0]input_index = 0,
    output reg signed [31:0] fp_value = 0,
    output reg [31:0] bcd_value = 0,
    output reg input_complete = 0,
    output reg [3:0]decimal_pos = 0
    );

    // Variables to store 8 BCD digits
    reg [3:0] bcd_digits[0:7];
    reg [3:0] valid_digits = 0;

    // Constants (Inputs)
    parameter CHECKMARK = 4'd12;
    parameter DECIMAL = 4'd10;
    parameter BACKSPACE = 4'd11;
    
    integer i;
    
    // Loop variables
    reg [7:0] removed_char;
    reg [7:0] ch;
    reg [3:0] digit_pos = 0;

    // Loop to update packed BCD value from individual digits
    always @ (*) begin
        bcd_value = {
            bcd_digits[7], bcd_digits[6], bcd_digits[5], bcd_digits[4],
            bcd_digits[3], bcd_digits[2], bcd_digits[1], bcd_digits[0]
        };
    end

    // Helper function to get/set characters in input_buffer
    function [7:0] get_char;
        input [3:0] index;
        begin
            case(index)
                0: get_char = input_buffer[7:0];
                1: get_char = input_buffer[15:8];
                2: get_char = input_buffer[23:16];
                3: get_char = input_buffer[31:24];
                4: get_char = input_buffer[39:32];
                5: get_char = input_buffer[47:40];
                6: get_char = input_buffer[55:48];
                7: get_char = input_buffer[63:56];
                default: get_char = " ";
            endcase
        end
    endfunction

    // Loop to process user input
    always @ (posedge clk) begin
        // Reset input_complete flag each cycle
        input_complete <= 0;

        // Reset all input states if in operand mode
        if (is_operand_mode) begin
            input_index <= 0;
            has_decimal <= 0;
            decimal_pos <= 4'hF;
            valid_digits <= 0;
            input_buffer <= 0;

            // We do not reset fp value here since the arithmetic_backend module will use it for computation

            // Clearing input_buffer and bcd_digits
            for (i = 0; i < 8; i = i + 1) begin
                bcd_digits[i] <= 0;
            end
        end

        // Process button presses in keypad mode
        else if (keypad_btn_pressed) begin
            case (selected_keypad_value)
                DECIMAL: begin
                    if (!has_decimal && input_index < 8) begin
                        has_decimal <= 1;
                        decimal_pos <= valid_digits;

                        // Set decimal point in appropriate position of input_buffer
                        case(input_index)
                            0: input_buffer[7:0] <= ".";
                            1: input_buffer[15:8] <= ".";
                            2: input_buffer[23:16] <= ".";
                            3: input_buffer[31:24] <= ".";
                            4: input_buffer[39:32] <= ".";
                            5: input_buffer[47:40] <= ".";
                            6: input_buffer[55:48] <= ".";
                            7: input_buffer[63:56] <= ".";
                        endcase

                        input_index <= input_index + 1;
                    end
                end

                BACKSPACE: begin
                    if (input_index > 0) begin
                        input_index <= input_index - 1;
                        
                        case(input_index-1)
                            0: removed_char = input_buffer[7:0];
                            1: removed_char = input_buffer[15:8];
                            2: removed_char = input_buffer[23:16];
                            3: removed_char = input_buffer[31:24];
                            4: removed_char = input_buffer[39:32];
                            5: removed_char = input_buffer[47:40];
                            6: removed_char = input_buffer[55:48];
                            7: removed_char = input_buffer[63:56];
                            default: removed_char = " ";
                        endcase

                        // Check if removing decimal point
                        if (removed_char == ".") begin
                            has_decimal <= 0;
                            decimal_pos <= 4'hF;
                        end
                        // Removing a digit
                        else begin
                            valid_digits <= valid_digits - 1;
                            
                            // Find position in bcd_digits that corresponds to this character
                            // (This is complex since we need to map input_index to valid_digits position)
                            // For simplicity, we'll rebuild the bcd_digits from input_buffer
                            
                            
                            // Clear the bcd array first
                            for (i = 0; i < 8; i = i + 1) begin
                                bcd_digits[i] <= 0;
                            end
                            
                            // Rebuild digits from remaining characters
                            for (i = 0; i < input_index-1; i = i + 1) begin
                                
                                
                                case(i)
                                    0: ch = input_buffer[7:0];
                                    1: ch = input_buffer[15:8];
                                    2: ch = input_buffer[23:16];
                                    3: ch = input_buffer[31:24];
                                    4: ch = input_buffer[39:32];
                                    5: ch = input_buffer[47:40];
                                    6: ch = input_buffer[55:48];
                                    7: ch = input_buffer[63:56];
                                endcase
                                
                                if (ch != ".") begin
                                    bcd_digits[digit_pos] <= ch - "0";
                                    digit_pos <= digit_pos + 1;
                                end
                            end
                        end

                        // Clear the deleted character in buffer
                        case(input_index-1)
                            0: input_buffer[7:0] <= " ";
                            1: input_buffer[15:8] <= " ";
                            2: input_buffer[23:16] <= " ";
                            3: input_buffer[31:24] <= " ";
                            4: input_buffer[39:32] <= " ";
                            5: input_buffer[47:40] <= " ";
                            6: input_buffer[55:48] <= " ";
                            7: input_buffer[63:56] <= " ";
                        endcase
                        
                        // Shift remaining characters left
                        for (i = input_index-1; i < 7; i = i + 1) begin
                            case(i)
                                0: input_buffer[7:0] <= input_buffer[15:8];
                                1: input_buffer[15:8] <= input_buffer[23:16];
                                2: input_buffer[23:16] <= input_buffer[31:24];
                                3: input_buffer[31:24] <= input_buffer[39:32];
                                4: input_buffer[39:32] <= input_buffer[47:40];
                                5: input_buffer[47:40] <= input_buffer[55:48];
                                6: input_buffer[55:48] <= input_buffer[63:56];
                            endcase
                        end
                        input_buffer[63:56] <= " ";
                    end
                end

                CHECKMARK: begin
                    if (input_index > 0) begin
                        // Converting BCD to fixed point representation
                        fp_value <= convert_to_fixed_point(valid_digits, decimal_pos);
                        input_complete <= 1;
                    end
                end

                // Process digits
                default: begin
                    // Only accept if we have room (max 8 including decimal)
                    if (input_index < 8 && valid_digits < 8) begin
                        // Store ASCII character for display
                        case(input_index)
                            0: input_buffer[7:0] <= selected_keypad_value + "0";
                            1: input_buffer[15:8] <= selected_keypad_value + "0";
                            2: input_buffer[23:16] <= selected_keypad_value + "0";
                            3: input_buffer[31:24] <= selected_keypad_value + "0";
                            4: input_buffer[39:32] <= selected_keypad_value + "0";
                            5: input_buffer[47:40] <= selected_keypad_value + "0";
                            6: input_buffer[55:48] <= selected_keypad_value + "0";
                            7: input_buffer[63:56] <= selected_keypad_value + "0";
                        endcase

                        // Store BCD digit
                        bcd_digits[valid_digits] <= selected_keypad_value;

                        // Increment indexes
                        input_index <= input_index + 1;
                        valid_digits <= valid_digits + 1;
                    end
                end
            endcase
        end

        // System reset
        if (reset) begin
            input_index <= 0;
            has_decimal <= 0;
            decimal_pos <= 4'hF;
            valid_digits <= 0;
            fp_value <= 0;
            input_complete <= 0;
            input_buffer <= 0;  // Clear all characters

            for (i = 0; i < 8; i = i + 1) begin
                bcd_digits[i] <= 0;
            end
        end
    end

    // Function to convert BCD to fixed point (Q16.16)
    function signed [31:0] convert_to_fixed_point(
        input [3:0] valid_digits, 
        input [3:0] decimal_pos
    );
        reg [31:0] integer_part;
        reg [31:0] fractional_part;
        reg [31:0] power_of_ten;
        integer i;  // Declare loop variable outside
    
        begin
            integer_part = 0;
            fractional_part = 0;
            power_of_ten = 1;

            // Calculate integer part
            if (decimal_pos == 4'hF) begin
                // No decimal point, all digits are integer part
                for (i = 0; i < valid_digits; i = i + 1) begin
                    integer_part = (integer_part * 10) + bcd_digits[i];
                end 
            end
            else begin
                // Process digits before decimal point
                for (i = 0; i < decimal_pos; i = i + 1) begin
                    integer_part = (integer_part * 10) + bcd_digits[i];
                end

                // Digits after decimal point
                for (i = decimal_pos; i < valid_digits; i = i + 1) begin
                    power_of_ten = power_of_ten * 10;
                    fractional_part = fractional_part + (bcd_digits[i] * 65536) / power_of_ten;
                end
            end

            // Combine integer and fractional parts
            convert_to_fixed_point = (integer_part << 16) + fractional_part;
        end
    endfunction

endmodule
