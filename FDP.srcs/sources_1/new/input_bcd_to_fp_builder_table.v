`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2025 11:56:43
// Design Name: 
// Module Name: input_bcd_to_fp_builder_table
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


module input_bcd_to_fp_builder_table(
    input clk,
    input keypad_btn_pressed,
    input [3:0] selected_keypad_value,
    input is_table_input_mode,
    input reset,
    output reg has_decimal = 0,
    output reg has_negative = 0,
    output reg [3:0] input_index = 0,
    output reg signed [31:0] fp_value = 0,
    output reg [31:0] bcd_value = 0,
    output reg input_complete = 0,
    output reg [3:0] decimal_pose = 4'hF
    );

    // Variables to store 8 BCD digits
    reg [3:0] bcd_digits[0:7];
    reg [3:0] valid_digits = 0;

    // Constants (Inputs)
    parameter CHECKMARK = 4'd12;
    parameter DECIMAL = 4'd10;
    parameter NEGATIVE = 4'd11;

    integer i;

    // Loop to update packed BCD value from individual digits
    always @ (*) begin
        bcd_value = {
            bcd_digits[7], bcd_digits[6], bcd_digits[5], bcd_digits[4],
            bcd_digits[3], bcd_digits[2], bcd_digits[1], bcd_digits[0]
        };
    end

    // Loop to process user input
    always @ (posedge clk) begin
        // Reset input_complete flag on each cycle
        input_complete <= 0;

        // Reset all states if not in table input mode
        if (!is_table_input_mode) begin
            input_index <= 0;
            has_decimal <= 0;
            has_negative <= 0;
            decimal_pos <= 4'hF;
            valid_digits <= 0;

            // Clearing bcd_digits
            for (i = 0; i < 8; i = i + 1) begin
                bcd_digits[i] = 0;
            end
        end
        else if (keypad_btn_pressed) begin
            // In table input mode, check what value was selected
            case (selected_keypad_value)
                CHECKMARK: begin
                    // Convert bcd into fp representation and complete input (note the use of =)
                    fp_value = convert_to_fixed_point(valid_digits, decimal_pose);
                    if (has_negative) begin
                        fp_value <= -fp_value;
                    end
                    input_complete <= 1;
                end

                DECIMAL: begin
                    if (!has_decimal && input_index > 0) begin
                        has_decimal <= 1;
                        decimal_pos <= valid_digits;
                    end
                end

                NEGATIVE: begin
                    // Adding negative sign only at the start
                    if (input_index == 0 && !has_negative) begin
                        has_negative <= 1;
                    end
                end

                default: begin
                    if (input_index < 8) begin
                        bcd_digits[input_index] <= selected_keypad_value;
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
            has_negative <= 0;
            decimal_pos <= 4'hF;
            valid_digits <= 0;
            fp_value <= 0;
            
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
        integer i;
    
        begin
            integer_part = 0;
            fractional_part = 0;
            power_of_ten = 1;

            // Calculate integer part
            if (decimal_pos == 4'hF) begin
                // No decimal point, all digits are integer part
                for (i = 0; i < 8; i = i + 1) begin  // Fixed upper bound
                    if (i < valid_digits) begin       // Only process valid digits
                        integer_part = (integer_part * 10) + bcd_digits[i];
                    end
                end 
            end
            else begin
                // Process digits before decimal point (fixed bound)
                for (i = 0; i < 8; i = i + 1) begin   // Fixed upper bound
                    if (i < decimal_pos) begin        // Only process relevant digits
                        integer_part = (integer_part * 10) + bcd_digits[i];
                    end
                end

                // Process digits after decimal point (fixed bound)
                power_of_ten = 1;
                for (i = 0; i < 8; i = i + 1) begin   // Fixed upper bound
                    if (i >= decimal_pos && i < valid_digits) begin  // Only process relevant digits
                        power_of_ten = power_of_ten * 10;
                        fractional_part = fractional_part + (bcd_digits[i] * 65536) / power_of_ten;
                    end
                end
            end

            // Combine integer and fractional parts
            convert_to_fixed_point = (integer_part << 16) + fractional_part;
        end
    endfunction
endmodule
