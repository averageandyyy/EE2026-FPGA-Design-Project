`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2025 16:14:30
// Design Name: 
// Module Name: arithmetic_input_display
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
This module is responsible for converting the input that the user keys in during arithmetic mode into a string
that is to be rendered via string_renderer_optimized.

A higher level module will make the decision as to whether to render this input or the result.

Theoretically, this module listens for changes in input from input_builder and regenerates the string based on the bcd input
to be rendered.
*/
module arithmetic_input_display(
    input clk,
    input [12:0] pixel_index,
    input [31:0] bcd_value,
    input [3:0] decimal_pos,
    input [3:0] input_index,
    input has_decimal,
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
    
    // Extract individual BCD digits
    wire [3:0] digits[0:7];
    assign digits[0] = bcd_value[3:0];
    assign digits[1] = bcd_value[7:4];
    assign digits[2] = bcd_value[11:8];
    assign digits[3] = bcd_value[15:12];
    assign digits[4] = bcd_value[19:16];
    assign digits[5] = bcd_value[23:20];
    assign digits[6] = bcd_value[27:24];
    assign digits[7] = bcd_value[31:28];
    
    // Character storage for the string to display
    reg [47:0] display_string = 48'hFFFFFFFFFFFF; // All spaces initially
    
    // Change detection
    reg [3:0] prev_input_index = 0;
    reg prev_has_decimal = 0;
    reg [3:0] prev_decimal_pos = 0;
    reg [31:0] prev_bcd_value = 0;
    
    // State machine
    reg [2:0] state = 0;
    parameter IDLE = 0;
    parameter START_UPDATE = 1;
    parameter PROCESS_DIGIT = 2;
    parameter RENDER = 3;
    
    // Processing variables
    reg [3:0] i = 0;     
    reg [3:0] bcd_pos = 0;     

    // String renderer output
    wire [15:0] string_data;
    wire string_active;
    
    // String renderer
    string_renderer_optimized renderer(
        .clk(clk),
        .word(display_string),
        .start_x(TEXT_START_X),
        .start_y(TEXT_START_Y),
        .pixel_index(pixel_index),
        .colour(BLACK),
        .oled_data(string_data),
        .active_pixel(string_active)
    );
    
    // Cursor variables
    reg [6:0] cursor_x;
    wire cursor_active = (x >= cursor_x && x < cursor_x + 8 && 
                         y >= TEXT_START_Y + 10 && y < TEXT_START_Y + 12);
    reg [3:0] cursor_blink_counter = 0;
    reg cursor_visible = 1;
    
    // State machine to update the display string
    always @ (posedge clk) begin
        // Update cursor position
        cursor_x <= TEXT_START_X + input_index * 8;
        
        // Blink cursor
        cursor_blink_counter <= cursor_blink_counter + 1;
        if (cursor_blink_counter == 15) begin
            cursor_visible <= ~cursor_visible;
            cursor_blink_counter <= 0;
        end
        
        // Check if any inputs have changed
        if (input_index != prev_input_index || has_decimal != prev_has_decimal || 
            decimal_pos != prev_decimal_pos || bcd_value != prev_bcd_value) begin
            state <= START_UPDATE;
            prev_input_index <= input_index;
            prev_has_decimal <= has_decimal;
            prev_decimal_pos <= decimal_pos;
            prev_bcd_value <= bcd_value;
        end
        
        // State machine
        case (state)
            IDLE: begin
                // Wait for changes
            end
            
            START_UPDATE: begin
                // Reset processing variables
                i <= 0;
                bcd_pos <= 0;
                display_string <= 48'hFFFFFFFFFFFF; // All spaces
                
                // Handle special case of empty input
                if (input_index == 0) begin
                    state <= RENDER;
                end
                else begin
                    state <= PROCESS_DIGIT;
                end
            end
            
            PROCESS_DIGIT: begin
                if (i < input_index && i < 8) begin
                    if (has_decimal && i == decimal_pos) begin
                        // Insert decimal point at this position
                        display_string[47 - i*6 -: 6] <= 6'd14; // Decimal point
                        i <= i + 1;
                    end
                    else begin
                        // Insert digit from BCD value
                        display_string[47 - i*6 -: 6] <= digits[bcd_pos];
                        i <= i + 1;
                        bcd_pos <= bcd_pos + 1;
                    end
                end
                else begin
                    // Finished processing all positions
                    state <= RENDER;
                end
            end
            
            RENDER: begin
                state <= IDLE;
            end
        endcase
    end
    
    // Main rendering logic
    always @(*) begin
        // Default to white background
        oled_data = WHITE;
        
        // Render string
        if (string_active) begin
            oled_data = string_data;
        end
        
        // Render blinking cursor
        if (cursor_active && cursor_visible) begin
            oled_data = BLACK;
        end
    end
endmodule