`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2025 13:46:12
// Design Name: 
// Module Name: integral_result_display
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


module integral_result_display(
    input clk,
    input [12:0] pixel_index,
    input signed [31:0] integral_result,
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
    parameter GREEN = 16'h07E0;
    
    // Display constants
    parameter TEXT_START_X = 8;
    parameter TEXT_START_Y = 32;
    parameter TITLE_Y = 10;
    
    // Title text "RESULT"
    reg [47:0] title_text = {6'd33, 6'd19, 6'd34, 6'd36, 6'd26, 6'd35, 6'd32, 6'd32};
    
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
    wire [15:0] result_string_data;
    wire result_string_active;
    wire [15:0] title_string_data;
    wire title_string_active;
    
    // Conversion refresh counter
    reg [15:0] refresh_counter = 0;
    
    // Instantiate fp_to_string_sequential
    fp_to_string_sequential converter(
        .clk(clk),
        .start_conversion(start_conversion),
        .fp_value(integral_result),
        .conversion_done(conversion_done),
        .result(result_string)
    );
    
    // Instantiate string renderers
    string_renderer_optimized result_renderer(
        .clk(clk),
        .word(result_string),
        .start_x(TEXT_START_X),
        .start_y(TEXT_START_Y),
        .pixel_index(pixel_index),
        .colour(GREEN),  // Use green for result value
        .oled_data(result_string_data),
        .active_pixel(result_string_active)
    );
    
    string_renderer_optimized title_renderer(
        .clk(clk),
        .word(title_text),
        .start_x(WIDTH/2 - 28),  // Center the title
        .start_y(TITLE_Y),
        .pixel_index(pixel_index),
        .colour(BLUE),  // Blue for title
        .oled_data(title_string_data),
        .active_pixel(title_string_active)
    );
    
    // Conversion state machine
    always @(posedge clk) begin
        // Default - clear start conversion flag
        start_conversion <= 0;
        
        // Increment refresh counter for periodic updates
        refresh_counter <= refresh_counter + 1;
        
        case (state)
            IDLE: begin
                // Check if result has changed
                if (integral_result != prev_result) begin
                    prev_result <= integral_result;
                    start_conversion <= 1;
                    state <= CONVERTING;
                    refresh_counter <= 0;
                end
                // Periodically refresh even if result hasn't changed
                // (helps with initial display and potential synchronization issues)
                else if (refresh_counter >= 16'h1FFF) begin
                    start_conversion <= 1;
                    state <= CONVERTING;
                    refresh_counter <= 0;
                end
            end
            
            CONVERTING: begin
                // Wait for conversion to complete
                if (conversion_done) begin
                    state <= DISPLAY;
                    refresh_counter <= 0;
                end
            end
            
            DISPLAY: begin
                // Display string for a while, then go back to IDLE
                // This creates a periodic refresh cycle
                if (refresh_counter >= 16'h7FFF) begin
                    state <= IDLE;
                    refresh_counter <= 0;
                end
            end
            
            default: state <= IDLE;
        endcase
    end
    
    // Main rendering logic
    always @(*) begin
        // Default white background
        oled_data = WHITE;
        
        // Add decorative border
        if (x == 0 || x == WIDTH-1 || y == 0 || y == HEIGHT-1) begin
            oled_data = BLUE;
        end
        
        // Add separator line below title
        if (y == TITLE_Y + 10) begin
            oled_data = BLUE;
        end
        
        // Render title
        if (title_string_active) begin
            oled_data = title_string_data;
        end
        
        // Render result string
        if (result_string_active) begin
            oled_data = result_string_data;
        end
    end
endmodule
