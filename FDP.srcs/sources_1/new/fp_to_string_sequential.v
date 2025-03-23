`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2025 14:50:22
// Design Name: 
// Module Name: fp_to_string_sequential
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
The idea for this module is for it replace to fp_to_string function, which makes use of combinational logic for everything to happen in parallel
which is expensive in terms of LUT consumption. With FSMs, we reduce the amount of parallel logic and hence LUT consumption. To be verified.
*/
module fp_to_string_sequential(
    input clk,
    input start_conversion,
    input signed [31:0] fp_value,
    output reg conversion_done,
    output reg [47:0] result
    );
    
    // States
    localparam IDLE               = 0;
    localparam EXTRACT_SIGN       = 1;
    localparam COUNT_DIGITS       = 2;
    localparam EXTRACT_INT_DIGITS = 3;
    localparam EXTRACT_FRAC_DIGITS= 4;
    localparam FORMAT_STRING      = 5;
    localparam DONE               = 6;
    
    reg [2:0] state = IDLE;
    
    // Internal variables
    reg         is_negative;
    reg [31:0]  abs_value;
    reg [31:0]  int_part;
    reg [31:0]  frac_part;
    reg [31:0]  temp_int;   // temporary copy of int_part for counting digits
    reg [3:0]   int_digits; // Number of digits in the integer part
    reg [3:0]   digit_values[0:9]; // Will store up to 9 digits (max 5 integer + 4 fractional)
    reg [5:0]   char_codes[0:7];   // 8 characters, 6 bits each
    reg [3:0]   i;          // loop counter
    reg [3:0]   digit_count; // count of characters placed into string
    reg [31:0]  temp_frac;  // temporary copy of frac_part for extraction
    
    always @(posedge clk) begin
        case (state)
            IDLE: begin
                conversion_done <= 0;
                if (start_conversion) begin
                    // Reset variables
                    digit_count <= 0;
                    i <= 0;
                    int_digits <= 0;
                    // Initialize char_codes to blanks (here, using 6'b111111 as a blank)
                    char_codes[0] <= 6'b111111;
                    char_codes[1] <= 6'b111111;
                    char_codes[2] <= 6'b111111;
                    char_codes[3] <= 6'b111111;
                    char_codes[4] <= 6'b111111;
                    char_codes[5] <= 6'b111111;
                    char_codes[6] <= 6'b111111;
                    char_codes[7] <= 6'b111111;
                    state <= EXTRACT_SIGN;
                end
            end
            
            EXTRACT_SIGN: begin
                // Determine sign and compute absolute value
                is_negative <= (fp_value < 0);
                abs_value <= (fp_value < 0) ? -fp_value : fp_value;
                
                // Split into integer and fractional parts
                int_part <= (fp_value < 0 ? -fp_value : fp_value) >> 16;
                frac_part <= (((fp_value < 0 ? -fp_value : fp_value) & 16'hFFFF) * 10000) >> 16;
                // Copy int_part for counting
                temp_int <= (fp_value < 0 ? -fp_value : fp_value) >> 16;
                state <= COUNT_DIGITS;
                i <= 0;
                int_digits <= 0;
            end
            
            COUNT_DIGITS: begin
                // Sequentially count digits using temp_int.
                if (temp_int > 0) begin
                    int_digits <= int_digits + 1;
                    temp_int <= temp_int / 10;
                end else begin
                    // If no digits counted, then number is 0.
                    if (int_digits == 0)
                        int_digits <= 1;
                    // Restore int_part for extraction
                    int_part <= (fp_value < 0 ? -fp_value : fp_value) >> 16;
                    i <= 0;
                    state <= EXTRACT_INT_DIGITS;
                end
            end
            
            EXTRACT_INT_DIGITS: begin
                // Extract integer digits from int_part.
                // Process one digit per cycle until we've extracted int_digits digits.
                if (i < int_digits) begin
                    // Extract least significant digit and store it in reverse order.
                    digit_values[int_digits - i - 1] <= int_part % 10;
                    int_part <= int_part / 10;
                    i <= i + 1;
                end else begin
                    // Move on to extracting fractional digits
                    state <= EXTRACT_FRAC_DIGITS;
                    i <= 0;
                    temp_frac <= frac_part;
                end
            end
            
            EXTRACT_FRAC_DIGITS: begin
                // Extract exactly 4 fractional digits sequentially.
                if (i < 4) begin
                    // Store the fractional digit at position int_digits+1+i.
                    digit_values[int_digits + 1 + i] <= temp_frac / 1000;
                    temp_frac <= (temp_frac % 1000) * 10;
                    i <= i + 1;
                end else begin
                    state <= FORMAT_STRING;
                    i <= 0;
                    digit_count <= 0;
                end
            end
            
            FORMAT_STRING: begin
                // Build the output string sequentially.
                // We will use the following order:
                // 1. Negative sign (if needed) -- processed only once.
                // 2. Integer digits (there are int_digits digits)
                // 3. Decimal point (if space available, at least 2 spaces must remain)
                // 4. Fractional digits (4 digits)
                if (i == 0) begin
                    // Add negative sign if needed
                    if (is_negative && (digit_count < 8)) begin
                        char_codes[digit_count] <= 6'b001011; // Negative sign code
                        digit_count <= digit_count + 1;
                    end
                    i <= 1;
                end 
                else if (i <= int_digits) begin
                    // Add integer digits. (i from 1 to int_digits)
                    if (digit_count < 8) begin
                        // digit_values are stored with index 0 = most significant digit
                        case (digit_values[i-1])
                            4'd0: char_codes[digit_count] <= 6'd0;
                            4'd1: char_codes[digit_count] <= 6'd1;
                            4'd2: char_codes[digit_count] <= 6'd2;
                            4'd3: char_codes[digit_count] <= 6'd3;
                            4'd4: char_codes[digit_count] <= 6'd4;
                            4'd5: char_codes[digit_count] <= 6'd5;
                            4'd6: char_codes[digit_count] <= 6'd6;
                            4'd7: char_codes[digit_count] <= 6'd7;
                            4'd8: char_codes[digit_count] <= 6'd8;
                            4'd9: char_codes[digit_count] <= 6'd9;
                            default: char_codes[digit_count] <= 6'b111111; // blank
                        endcase
                        digit_count <= digit_count + 1;
                    end
                    i <= i + 1;
                end 
                else if (i == int_digits + 1) begin
                    // Insert decimal point if there's space (we require at least 2 characters left)
                    if (digit_count < 7) begin
                        char_codes[digit_count] <= 6'd14; // Decimal point code (14)
                        digit_count <= digit_count + 1;
                    end
                    i <= i + 1;
                end 
                else if (i < int_digits + 6) begin
                    // Add fractional digits. There are 4 fractional digits stored at indices int_digits+1 ... int_digits+4.
                    if (digit_count < 8) begin
                        case (digit_values[i - 1])
                            4'd0: char_codes[digit_count] <= 6'd0;
                            4'd1: char_codes[digit_count] <= 6'd1;
                            4'd2: char_codes[digit_count] <= 6'd2;
                            4'd3: char_codes[digit_count] <= 6'd3;
                            4'd4: char_codes[digit_count] <= 6'd4;
                            4'd5: char_codes[digit_count] <= 6'd5;
                            4'd6: char_codes[digit_count] <= 6'd6;
                            4'd7: char_codes[digit_count] <= 6'd7;
                            4'd8: char_codes[digit_count] <= 6'd8;
                            4'd9: char_codes[digit_count] <= 6'd9;
                            default: char_codes[digit_count] <= 6'b111111;
                        endcase
                        digit_count <= digit_count + 1;
                    end
                    i <= i + 1;
                end 
                else begin
                    state <= DONE;
                end
            end
            
            DONE: begin
                // Pack the 8 characters into the 48-bit result.
                result <= { char_codes[0], char_codes[1], char_codes[2], char_codes[3],
                            char_codes[4], char_codes[5], char_codes[6], char_codes[7] };
                conversion_done <= 1;
                state <= IDLE;
            end
            
            default: state <= IDLE;
        endcase
    end
endmodule

