`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2025 13:30:56
// Design Name: 
// Module Name: integral_input_display
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


module integral_input_display(
    input clk,
    input [12:0] pixel_index,
    input [31:0] bcd_value,
    input [3:0] decimal_pos,
    input [3:0] input_index,
    input has_decimal,
    input has_negative,
    input is_input_a,
    input is_input_b,
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
    parameter BLUE = 16'h001F;
    
    // Display constants
    parameter TEXT_START_X = 8;
    parameter TEXT_START_Y = 24;
    parameter LABEL_Y = 12;
    
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
    
    // Strings for labels
    reg [47:0] label_a = {6'd23, 6'd28, 6'd30, 6'd36, 6'd35, 6'd32, 6'd15, 6'd32}; // "INPUT A"
    reg [47:0] label_b = {6'd23, 6'd28, 6'd30, 6'd36, 6'd35, 6'd32, 6'd16, 6'd32}; // "INPUT B"
    reg [47:0] current_label;
    
    // Change detection
    reg [3:0] prev_input_index = 0;
    reg prev_has_decimal = 0;
    reg prev_has_negative = 0;
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

    // String renderer outputs
    wire [15:0] string_data;
    wire string_active;
    wire [15:0] label_data;
    wire label_active;
    
    // Input value renderer
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
    
    // Label renderer
    string_renderer_optimized label_renderer(
        .clk(clk),
        .word(current_label),
        .start_x(TEXT_START_X),
        .start_y(LABEL_Y),
        .pixel_index(pixel_index),
        .colour(BLUE),  // Use blue for the label
        .oled_data(label_data),
        .active_pixel(label_active)
    );
    
    // Cursor variables
    reg [6:0] cursor_x;
    wire cursor_active = (x >= cursor_x && x < cursor_x + 8 && 
                         y >= TEXT_START_Y + 10 && y < TEXT_START_Y + 12);
    reg [3:0] cursor_blink_counter = 0;
    reg cursor_visible = 1;
    
    // Update label based on is_input_a and is_input_b
    always @(*) begin
        if (is_input_a) begin
            current_label = label_a;
        end else if (is_input_b) begin
            current_label = label_b;
        end else begin
            current_label = 48'hFFFFFFFFFFFF; // All spaces if no label needed
        end
    end
    
    // State machine to update the display string
    always @(posedge clk) begin
        // Update cursor position
        cursor_x <= TEXT_START_X + input_index * 8;
        
        // Blink cursor
        cursor_blink_counter <= cursor_blink_counter + 1;
        if (cursor_blink_counter == 15) begin
            cursor_visible <= ~cursor_visible;
            cursor_blink_counter <= 0;
        end
        
        // Check if any inputs have changed
        if (input_index != prev_input_index || 
            has_decimal != prev_has_decimal || 
            has_negative != prev_has_negative ||
            decimal_pos != prev_decimal_pos || 
            bcd_value != prev_bcd_value) begin
            state <= START_UPDATE;
            prev_input_index <= input_index;
            prev_has_decimal <= has_decimal;
            prev_has_negative <= has_negative;
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
                    // If there's a negative sign, we need to handle it first
                    if (has_negative) begin
                        display_string[47:42] <= 6'd11; // Negative sign
                        i <= 1; // Start processing from position 1
                    end
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
        
        // Render label (if active)
        if (label_active) begin
            oled_data = label_data;
        end
        
        // Render input string
        if (string_active) begin
            oled_data = string_data;
        end
        
        // Render blinking cursor
        if (cursor_active && cursor_visible) begin
            oled_data = BLACK;
        end
    end
endmodule
