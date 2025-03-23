`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.03.2025 08:30:30
// Design Name: 
// Module Name: polynomial_table_table_display
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


module polynomial_table_table_display(
    input clk,
    input [12:0] pixel_index,
    input is_table_mode,
    
    // From polynomial_table_cursor_controller
    input signed [31:0] starting_x,

    // From some other module (likely wayne's)
    input signed [31:0] coeff_a,
    input signed [31:0] coeff_b,
    input signed [31:0] coeff_c,
    input signed [31:0] coeff_d,

    output reg [15:0] oled_data
    );

    // OLED dimensions
    parameter WIDTH = 96;
    parameter HEIGHT = 64;
    
    // Table layout constants
    parameter ROW_HEIGHT = 12;
    parameter COL_WIDTH = 48;
    parameter HEADER_HEIGHT = 12;
    parameter TABLE_ROWS = 5;

    // Colors
    parameter WHITE = 16'hFFFF;
    parameter BLACK = 16'h0000;

    // Extract pixel coordinates
    wire [6:0] x = pixel_index % WIDTH;
    wire [6:0] y = pixel_index / WIDTH;

    // Variables to store computed values
    reg signed [31:0] x_values[0:9];
    reg signed [31:0] y_values[0:9];

    // For fixed point to character conversion
    reg [47:0] x_text;
    reg [47:0] y_text;

    // String renderer instances for x and y columns
    wire [15:0] x_string_data;
    wire x_active;
    wire [15:0] y_string_data;
    wire y_active;

    // Row detection
    wire [3:0] current_row = (y - HEADER_HEIGHT) / ROW_HEIGHT;
    wire in_header = (y < HEADER_HEIGHT);
    wire in_table_body = (y>= HEADER_HEIGHT && current_row < TABLE_ROWS);

    // For polynomial computations
    reg signed [63:0] x_squared, x_cubed;
    reg signed [63:0] term_a, term_b, term_c;
    reg signed [63:0] sum;

    // String renderer for x values
    string_renderer_optimized x_renderer(
        .clk(clk),
        .word(x_text),
        .start_x(4),
        .start_y(in_header ? 1 : HEADER_HEIGHT + current_row * ROW_HEIGHT + 1),
        .pixel_index(pixel_index),
        .colour(BLACK),
        .oled_data(x_string_data),
        .active_pixel(x_active)
    );

    // String renderer for y values
    string_renderer_optimized y_renderer(
        .clk(clk),
        .word(y_text),
        .start_x(COL_WIDTH + 4),
        .start_y(in_header ? 1 : HEADER_HEIGHT + current_row * ROW_HEIGHT + 1),
        .pixel_index(pixel_index),
        .colour(BLACK),
        .oled_data(y_string_data),
        .active_pixel(y_active)
    );

    // Helper function to convert a fixed point value to a character string
    function [47:0] fp_to_string(
        input signed [31:0] fp_value
    );
        reg is_negative;
        reg [31:0] abs_value;
        reg [31:0] int_part;
        reg [31:0] frac_part;
        reg [3:0] int_digits;
        reg [3:0] digit_values[0:8];
        reg [5:0] char_codes[0:7];
        integer i, j, digit_count;

        begin
            // Determine sign
            is_negative = (fp_value < 0);
            abs_value = is_negative ? -fp_value : fp_value;

            // Split into integer and fractional parts
            int_part = abs_value >> 16;
            frac_part = ((abs_value & 16'hFFFF) * 10000) >> 16; // Scales fractional part to 4 decimals

            // Count integer digits
            if (int_part == 0) begin
                int_digits = 1;
            end
            else begin
                int_digits = 0;
                // Use a fixed loop with a maximum of 10 digits (far more than needed)
                for (i = 0; i < 10; i = i + 1) begin
                    if (int_part > 0) begin
                        int_digits = int_digits + 1;
                        int_part = int_part / 10;
                    end
                end
                // Restore int_part after counting
                int_part = abs_value >> 16;
            end 

            // Extract digits (integer part) - using fixed bounds
            for (i = 0; i < 8; i = i + 1) begin
                if (i < int_digits) begin
                    digit_values[int_digits - i - 1] = int_part % 10;
                    int_part = int_part / 10;
                end
            end

            // Extract digits (fractional part)
            for (i = 0; i < 4; i = i + 1) begin 
                digit_values[int_digits + 1 + i] = frac_part / 1000;
                frac_part = (frac_part % 1000) * 10;
            end

            // Initialize all characters to space/blank
            for (i = 0; i < 8; i = i + 1) begin
                char_codes[i] = 6'b111111; // Nonsense value so that it defaults to blank (see sprite_library.v)
            end

            // Format string for display
            digit_count = 0;
        
            // Adding negative sign if present
            if (is_negative && digit_count < 8) begin
                char_codes[digit_count] = 6'b001011; // Negative/minus sign code
                digit_count = digit_count + 1;
            end

            // Add integer digits (with fixed loop bounds)
            for (i = 0; i < 8; i = i + 1) begin
                if (i < int_digits && digit_count < 8) begin
                    char_codes[digit_count] = {2'b00, digit_values[i]};
                    digit_count = digit_count + 1;
                end
            end

            // Add decimal point and fractional part depending on space, use at least 2 spots 1 for dp and 1 for digit
            if (digit_count < 7) begin
                char_codes[digit_count] = 6'b001110; // Decimal point (code 14)
                digit_count = digit_count + 1;

                // Add fractional
                for (i = 0; i < 4; i = i + 1) begin
                    if (digit_count < 8) begin
                        char_codes[digit_count] = {2'b00, digit_values[int_digits + i + 1]};
                        digit_count = digit_count + 1;
                    end
                end
            end

            // Pack all characters into 48-bit output
            fp_to_string = {
                char_codes[0], char_codes[1], char_codes[2], char_codes[3],
                char_codes[4], char_codes[5], char_codes[6], char_codes[7]
            };
        end
    endfunction

    // Compute table values at initialization
    integer i;
    initial begin
        for (i = 0; i < 10; i = i + 1) begin
            x_values[i] = 0;
            y_values[i] = 0;
        end
    end

    // Updating computations when starting_x changes
    always @ (posedge clk) begin
        if (is_table_mode) begin
            for (i = 0; i < 10; i = i + 1) begin
                x_values[i] = starting_x + (i << 16); // Adding i in fixed point

                // Calculate polynomial
                x_squared = ((x_values[i] * x_values[i]) >>> 16); // Signed shift right
                x_cubed = ((x_squared * x_values[i]) >>> 16);

                term_a = ((coeff_a * x_cubed) >>> 16);
                term_b = ((coeff_b * x_squared) >>> 16);
                term_c = ((coeff_c * x_values[i]) >>> 16);

                y_values[i] = term_a[31:0] + term_b[31:0] + term_c[31:0] + coeff_d;
            end
        end
    end

    // Display logic
    always @ (posedge clk) begin
        if (is_table_mode) begin
            // Default white background
            oled_data = WHITE;

            // Table grid
            if (x ==  0 || x == WIDTH - 1 || x == COL_WIDTH ||
                y == 0 || y == HEIGHT - 1 || y == HEADER_HEIGHT ||
                (y > HEADER_HEIGHT && (y - HEADER_HEIGHT) % ROW_HEIGHT == 0 && y < HEADER_HEIGHT + TABLE_ROWS * ROW_HEIGHT)
            ) begin
                oled_data = BLACK;
            end
            else begin
                // Table content
                if (in_header) begin
                    // Set Header text
                    if (x < COL_WIDTH) begin
                        // X header
                        x_text = {6'b100110, 6'b111111, 6'b111111, 6'b111111, 6'b111111, 6'b111111, 6'b111111, 6'b111111};
                        if (x_active) begin
                            oled_data = x_string_data;
                        end
                    end
                    else begin
                        // Y Header
                        y_text = {6'b100111, 6'b111111, 6'b111111, 6'b111111, 6'b111111, 6'b111111, 6'b111111, 6'b111111};
                        if (y_active) begin
                            oled_data = y_string_data;
                        end
                    end
                end
                else if (in_table_body) begin
                    // Data rows
                    if (x < COL_WIDTH) begin
                        // X value column
                        x_text = fp_to_string(x_values[current_row]);
                        if (x_active) begin
                            oled_data = x_string_data;
                        end
                    end
                    else begin
                        y_text = fp_to_string(y_values[current_row]);
                        if (y_active) begin
                            oled_data = y_string_data;
                        end
                    end
                end
            end
        end
        else begin
            oled_data = WHITE;
        end
    end
endmodule
