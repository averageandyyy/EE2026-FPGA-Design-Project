`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2025 16:21:12
// Design Name: 
// Module Name: arithmetic_input_result_renderer
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
This module is responsible for rendering either the user input or the calculation result
based on the current mode. It contains two sub-modules:
1. arithmetic_input_display - Renders the user input as they type
2. arithmetic_result_display - Renders the calculation result (to be implemented)
*/
module arithmetic_input_result_renderer(
    input clk,
    input [12:0] pixel_index,
    input signed [31:0] result,
    input is_operand_mode,
    input [31:0] bcd_value,
    input [3:0] decimal_pos,
    input [3:0] input_index,
    input has_decimal,
    output reg [15:0] oled_data
);
    // Outputs from the display modules
    wire [15:0] input_data;
    wire [15:0] result_data;
    
    // Instantiate the input display module
    arithmetic_input_display input_display(
        .clk(clk),
        .pixel_index(pixel_index),
        .bcd_value(bcd_value),
        .decimal_pos(decimal_pos),
        .input_index(input_index),
        .has_decimal(has_decimal),
        .oled_data(input_data)
    );

    // Instantiate the result display module
    arithmetic_result_display result_display(
        .clk(clk),
        .pixel_index(pixel_index),
        .result(result),
        .oled_data(result_data)
    );
    
    // Select which display to show based on the current mode
    always @(*) begin
        if (is_operand_mode)
            oled_data = result_data;  // Show calculation result
        else
            oled_data = input_data;   // Show user input
    end

endmodule