`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2025 00:32:26
// Design Name: 
// Module Name: arithmetic_result_display
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


module arithmetic_result_display(
    input clk,
    input [12:0] pixel_index,
    input signed [31:0] result,
    output reg [15:0] oled_data
);
    // OLED dimensions
    parameter WIDTH = 96;
    parameter HEIGHT = 64;

    // Extract pixel coordinates
    wire [6:0] x = pixel_index % WIDTH;
    wire [5:0] y = pixel_index / WIDTH;
    
    // Colors
    parameter WHITE = 16'hFFFF;
    parameter BLACK = 16'h0000;
    
    // Display constants
    parameter TEXT_START_X = 8;
    parameter TEXT_START_Y = 24;
    
    // Fixed-point to string conversion
    reg [31:0] prev_result = 0;
    reg start_conversion = 0;
    wire conversion_done;
    wire [47:0] result_string;
    
    // State machine for managing conversion
    reg [1:0] state = 0;
    parameter IDLE = 0;
    parameter CONVERTING = 1;
    parameter DISPLAY = 2;
    
    // String renderer outputs
    wire [15:0] string_data;
    wire string_active;
    
    // Instantiate fp_to_string_sequential
    fp_to_string_sequential converter(
        .clk(clk),
        .start_conversion(start_conversion),
        .fp_value(result),
        .conversion_done(conversion_done),
        .result(result_string)
    );
    
    // Instantiate string renderer
    string_renderer_optimized renderer(
        .clk(clk),
        .word(result_string),
        .start_x(TEXT_START_X),
        .start_y(TEXT_START_Y),
        .pixel_index(pixel_index),
        .colour(BLACK),
        .oled_data(string_data),
        .active_pixel(string_active)
    );
    
    // Conversion state machine
    always @(posedge clk) begin
        // Default - clear start conversion flag
        start_conversion <= 0;
        
        case (state)
            IDLE: begin
                // Check if result has changed
                if (result != prev_result) begin
                    prev_result <= result;
                    start_conversion <= 1;
                    state <= CONVERTING;
                end
                // Periodically refresh even if result hasn't changed
                // (helps with initial display and potential synchronization issues)
                else begin
                    start_conversion <= 1;
                    state <= CONVERTING;
                end
            end
            
            CONVERTING: begin
                // Wait for conversion to complete
                if (conversion_done) begin
                    state <= DISPLAY;
                end
            end
            
            DISPLAY: begin
                // Display string for a while, then go back to IDLE
                // This creates a periodic refresh cycle
                state <= IDLE;
            end
            
            default: state <= IDLE;
        endcase
    end
    
    // Main rendering logic
    always @(*) begin
        // Default white background
        oled_data = WHITE;
        
        // Render string
        if (string_active) begin
            oled_data = string_data;
        end
    end
endmodule
