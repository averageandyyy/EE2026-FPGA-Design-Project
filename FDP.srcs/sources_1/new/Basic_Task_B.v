`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2025 07:16:41 PM
// Design Name: 
// Module Name: basic_task_b
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


module basic_task_b(input basys_clock, btnU, btnC, btnD, output [7:0] JB);
    // When the program starts, three solid white squares of 13x13 pixels should appear vertically on the OLED. All the other parts are black.
    // OLED display: 96x64 (x by y)
    
    reg [31:0] counter_6p25 = 7;
    reg [31:0] counter_25 = 1;
    reg [31:0] counter_1 = 49999;
    wire my_6p25mHz_signal;
    wire my_25mHz_signal;
    wire my_1kHz_signal;
    
    flexible_clock_divider my_6p25mHz(.main_clock(basys_clock), .ticks(counter_6p25), .output_clock(my_6p25mHz_signal));
    flexible_clock_divider my_25mHz(.main_clock(basys_clock), .ticks(counter_25), .output_clock(my_25mHz_signal));
    flexible_clock_divider my_1kHz(.main_clock(basys_clock), .ticks(counter_1), .output_clock(my_1kHz_signal));

    reg reset = 0;
    reg [15:0] oled_data = 0;
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [12:0] pixel_index;
    
    Oled_Display display(
    .clk(my_6p25mHz_signal), 
    .reset(reset), 
    .frame_begin(frame_begin), 
    .sending_pixels(sending_pixels),
    .sample_pixel(sample_pixel), 
    .pixel_index(pixel_index), 
    .pixel_data(oled_data), 
    .cs(JB[0]), 
    .sdin(JB[1]), 
    .sclk(JB[3]), 
    .d_cn(JB[4]), 
    .resn(JB[5]), 
    .vccen(JB[6]),
    .pmoden(JB[7]));
    
    wire [6:0] x;
    wire [6:0] y;
    
    // Get the x and y coordinates.
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    reg [2:0] color_top_idx    = 3'b000; 
    reg [2:0] color_middle_idx = 3'b000;
    reg [2:0] color_bottom_idx = 3'b000;
    
    reg [31:0] debounce_counter_U = 0;
    reg [31:0] debounce_counter_C = 0;
    reg [31:0] debounce_counter_D = 0;
    
    reg btnU_prev = 0, btnC_prev = 0, btnD_prev = 0;
    
    always @ (posedge my_1kHz_signal) begin
    
        if (debounce_counter_U > 0) debounce_counter_U <= debounce_counter_U - 1;
        if (debounce_counter_C > 0) debounce_counter_C <= debounce_counter_C - 1;
        if (debounce_counter_D > 0) debounce_counter_D <= debounce_counter_D - 1;
    
        if (btnU && !btnU_prev && debounce_counter_U == 0) begin
            color_top_idx <= (color_top_idx >= 3'b101) ? 0 : color_top_idx + 1;
            debounce_counter_U <= 200; 
        end

        if (btnC && !btnC_prev && debounce_counter_C == 0) begin
            color_middle_idx <= (color_middle_idx >= 3'b101) ? 0 : color_middle_idx + 1;
            debounce_counter_C <= 200;
        end

        if (btnD && !btnD_prev && debounce_counter_D == 0) begin
            color_bottom_idx <= (color_bottom_idx >= 3'b101) ? 0 : color_bottom_idx + 1;
            debounce_counter_D <= 200; 
        end
        
        btnU_prev <= btnU;
        btnC_prev <= btnC;
        btnD_prev <= btnD;
    end
    
    // Color mapping
    function [15:0] get_color(input [2:0] color_idx);
    case (color_idx)
        3'b000: get_color = 16'b11111_111111_11111; // White
        3'b001: get_color = 16'b11111_000000_00000; // Red
        3'b010: get_color = 16'b00000_111111_00000; // Green
        3'b011: get_color = 16'b00000_000000_11111; // Blue
        3'b100: get_color = 16'b11111_100101_00000; // Orange
        3'b101: get_color = 16'b00000_000000_00000; // Black
        default: get_color = 16'b11111_111111_11111; // Wrap back to White
    endcase
    endfunction
    
    reg [31:0] x_c = 48;
    reg [31:0] y_c = 54;
    reg [31:0] r_squared = 36;
    
    // Initialisation
    always @ (posedge my_25mHz_signal)
    begin
        oled_data <= 16'b00000_000000_00000;

        if (x > 41 && x < 54) begin
            if (y > 2 && y < 15) begin
                oled_data <= get_color(color_top_idx);
            end
            if (y > 17 && y < 30) begin
                oled_data <= get_color(color_middle_idx);
            end
            if (y > 32 && y < 45) begin
                oled_data <= get_color(color_bottom_idx);
            end       
        end
        
        if (color_top_idx == 3'b001 && color_middle_idx == 3'b001 && color_bottom_idx == 3'b001) begin
            if ((x - x_c)*(x - x_c) + (y - y_c)*(y - y_c) <= r_squared) begin
                oled_data <= 16'b11111_000000_00000; 
            end        
        end 
        
        if (color_top_idx == 3'b100 && color_middle_idx == 3'b100 && color_bottom_idx == 3'b100) begin
            if ((x - x_c)*(x - x_c) + (y - y_c)*(y - y_c) <= r_squared) begin
                oled_data <= 16'b11111_100101_00000; 
            end        
        end 
        
    end
    
    // Up pushbutton = Change topmost square
    // Centre pushbutton = Change middle square
    // Down pushbutton = Change bottommost square

endmodule
