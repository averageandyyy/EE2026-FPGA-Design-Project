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


module arithmetic_backend(
    input clk,
    input reset,
    input input_complete,
    input signed [31:0] input_fp_value,
    input operand_btn_pressed,
    input [1:0] selected_operand_value,
    output reg is_operand_mode = 0,
    output reg signed [31:0] result = 0,
    output reg [1:0] current_operation = 0,
    output reg [1:0] operation_done = 0
    );

    // Operation constants
    parameter ADD = 2'd0;
    parameter SUBTRACT = 2'd1;
    parameter MULTIPLY = 2'd2;
    parameter DIVIDE = 2'd3;

    // Flag for first calculation
    reg is_first_calc = 1;

    always @ (posedge clk) begin
        // Reset operation_done
        operation_done <= 0;

        // System reset
        if (reset) begin
            is_operand_mode <= 0;
            result <= 0;
            current_operation <= ADD;
            operation_done <= 0;
            is_first_calc <= 1;
        end

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
                            result <= result + input_fp_value;
                        end

                        SUBTRACT: begin
                            result <= result - input_fp_value;
                        end

                        MULTIPLY: begin
                            // For Q16.16 multiplication, we need to shift right by 16
                            result <= (result * input_fp_value) >>> 16;
                        end

                        DIVIDE: begin
                            // For division, shift left by 16 instead
                            if (input_fp_value != 0) begin
                                result <= (result << 16) / input_fp_value;
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
endmodule
