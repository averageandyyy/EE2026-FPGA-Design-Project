`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2025 11:14:49
// Design Name: 
// Module Name: arithmetic_backend
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


(* use_dsp = "yes" *) module arithmetic_backend(
    input clk,
    input reset,
    input input_complete,
    input signed [31:0] input_fp_value,
    input operand_btn_pressed,
    input [1:0] selected_operand_value,
    output reg is_operand_mode = 0,
    output reg signed [31:0] result = 0,
    output reg [1:0] current_operation = 0,
    output reg [1:0] operation_done = 0,
    output reg overflow_flag = 0
    );

    // Operation constants
    parameter ADD = 2'd0;
    parameter SUBTRACT = 2'd1;
    parameter MULTIPLY = 2'd2;
    parameter DIVIDE = 2'd3; 

    // Flag for first calculation
    reg is_first_calc = 1;

    // Temporary variable for multiplication
    reg signed [63:0] product;
    reg signed [63:0] dividend;
    
    // Overflow detection flags
    reg overflow;
    reg [31:0] temp_result;

    always @ (posedge clk) begin
        // Reset operation_done and overflow
        operation_done <= 0;
        overflow <= 0;

        // System reset
        if (reset) begin
            is_operand_mode <= 0;
            result <= 0;
            current_operation <= ADD;
            operation_done <= 0;
            is_first_calc <= 1;
        end
        else begin
            // Mode transitions and operations
            if (!is_operand_mode) begin
                // In keypad mode, listen for input_complete
                if (input_complete) begin
                    // Switch modes
                    is_operand_mode <= 1;

                    // First calculation just simply involves storing the value
                    if (is_first_calc) begin
                        result <= input_fp_value;
                        is_first_calc <= 0;
                    end
                    else begin
                        // Perform calculation using current operation (or last registered operand)
                        case (current_operation)
                            ADD: begin
                                temp_result = result + input_fp_value;
                                // Overflow check: if both inputs positive but result negative, or both negative but result positive
                                overflow = ((result[31] == 0 && input_fp_value[31] == 0 && temp_result[31] == 1) || 
                                           (result[31] == 1 && input_fp_value[31] == 1 && temp_result[31] == 0));
                                result <= overflow ? 0 : temp_result;
                                overflow_flag <= overflow ? 1 : 1;
                            end

                            SUBTRACT: begin
                                temp_result = result - input_fp_value;
                                // Overflow check: if first positive, second negative but result negative, or first negative, second positive but result positive
                                overflow = ((result[31] == 0 && input_fp_value[31] == 1 && temp_result[31] == 1) || 
                                           (result[31] == 1 && input_fp_value[31] == 0 && temp_result[31] == 0));
                                result <= overflow ? 0 : temp_result;
                                overflow_flag <= overflow ? 1 : 1;
                            end

                            MULTIPLY: begin
                                // For Q16.16 multiplication, we need to shift right by 16
                                product = result * input_fp_value;
                                // Check for overflow: if high bits are not sign extension of low 32 bits
                                overflow = ((product[63:31] != {33{product[31]}}) && (product[63:31] != 33'h0));
                                result <= overflow ? 0 : (product >>> 16);
                                overflow_flag <= overflow ? 1 : 1;
                            end

                            DIVIDE: begin
                                // For division, shift left by 16 instead
                                if (input_fp_value != 0) begin
                                    // Extend the sign bit and result to 64-bits, then shift fractional part into integer part
                                    dividend = { {32{result[31]}}, result } <<< 16;
                                    temp_result = dividend / input_fp_value;
                                    // Check for overflow in division result
                                    overflow = ((temp_result[31] == 0 && dividend[63] == 1 && input_fp_value[31] == 0) ||
                                               (temp_result[31] == 1 && dividend[63] == 0 && input_fp_value[31] == 0) ||
                                               (temp_result[31] == 0 && dividend[63] == 0 && input_fp_value[31] == 1) ||
                                               (temp_result[31] == 1 && dividend[63] == 1 && input_fp_value[31] == 1));
                                    result <= overflow ? 0 : temp_result;
                                    overflow_flag <= overflow ? 1 : 1;
                                end
                                else begin
                                    // Division by zero case
                                    result <= 0;
                                end
                            end
                        endcase
                    end

                    operation_done <= 1;
                end
            end
            else begin
                // In operand mode, listen for operand selection
                if (operand_btn_pressed) begin
                    current_operation <= selected_operand_value;

                    // Mode switch
                    is_operand_mode <= 0;
                end
            end
        end
    end
endmodule
