`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.03.2025 19:12:23
// Design Name: 
// Module Name: cursor_controller
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
This module is responsible for registering the current cursor position. The cursor positions
will be passed into another module that will then generate the OLED data to be rendered.

The module will also be responsible for noting down what the user has inputted or "pressed
enter" on, ingesting the input to be passed on to future modules.

Note that the keypad generated should have the 10 digits from 0 to 9, a backspace (currently denoted by x)
and a decimal to input floating point values and a lone check mark on the far right for the user to indicate that 
they are down with the input.

On a 96x64 (rows by columns), we should be rendering 13 symbols. To fit the screen, we will make each symbol
occupy 24x16. Accounting for a 1px padding, the symbol itself should occupy 22x14. The checkmark will take up
a full column by itself and thus occupy a 24x64. It should be centred.

7 8 9
4 5 6
1 2 3    ^ (checkmark)
0 . x

On user selection, the user's choice will be outputted to a variable.

The module expects a 1kHz clock.
*/
module cursor_controller(
    input clk,
    input btnC,
    input btnU,
    input btnD,
    input btnL,
    input btnR,
    output reg [1:0]cursor_row = 0,
    output reg [2:0]cursor_col = 0,
    output reg btn_pressed = 0,
    output reg [3:0]selected_value
    );

    // Previous button states for debouncing
    reg prev_btnC = 0;
    reg prev_btnU = 0;
    reg prev_btnD = 0;
    reg prev_btnL = 0;
    reg prev_btnR = 0;

    // Debouncing counters
    reg [7:0] debounce_C = 0;
    reg [7:0] debounce_U = 0;
    reg [7:0] debounce_D = 0;
    reg [7:0] debounce_L = 0;
    reg [7:0] debounce_R = 0;

    // Flag to track if on the checkmark
    wire on_checkmark = (cursor_col == 3'd3);

    // Button handling loop
    always @ (posedge clk) begin
        // Reset button pressed signal each cycle
        btn_pressed <= 0;
        
        // Decrement debounce counters if active
        if (debounce_U > 0) debounce_U <= debounce_U - 1;
        if (debounce_D > 0) debounce_D <= debounce_D - 1;
        if (debounce_L > 0) debounce_L <= debounce_L - 1;
        if (debounce_R > 0) debounce_R <= debounce_R - 1;
        if (debounce_C > 0) debounce_C <= debounce_C - 1;

        // Up button processing
        if (btnU && !prev_btnU && debounce_U == 0) begin
            if (cursor_row > 0 && !on_checkmark) begin
                cursor_row <= cursor_row - 1;
            end
            debounce_U <= 200;
        end

        // Down
        if (btnD && !prev_btnD && debounce_D == 0) begin
            if (cursor_row < 3 && !on_checkmark) begin
                cursor_row <= cursor_row + 1;
            end
            debounce_D <= 200;
        end

        // Left
        if (btnL && !prev_btnL && debounce_L == 0) begin
            if (on_checkmark) begin
                // Moving left from checkmark goes to the main keypad
                cursor_col <= 3'd2;
            end else if (cursor_col > 0) begin
                cursor_col <= cursor_col - 1;
            end
            debounce_L <= 200;
        end

        // Right
        if (btnR && !prev_btnR && debounce_R == 0) begin
            if (!on_checkmark && cursor_col < 2) begin
                cursor_col <= cursor_col + 1;
            end else if (!on_checkmark && cursor_col == 2) begin
                cursor_col <= 3'd3;  // Go to checkmark column
            end
            debounce_R <= 200;
        end

        // Center (Selection)
        if (btnC && !prev_btnC && debounce_C == 0) begin
            btn_pressed <= 1;

            if (on_checkmark) begin
                // Checkmark selected
                selected_value <= 4'd12;  // Special value for checkmark
            end else begin
                // Determining selected value based on cursor position in main keypad
                case(cursor_row)
                    2'd0: selected_value <= cursor_col + 4'd7; // 7, 8, 9
                    2'd1: selected_value <= cursor_col + 4'd4; // 4, 5, 6
                    2'd2: selected_value <= cursor_col + 4'd1; // 1, 2, 3
                    2'd3: begin
                        case(cursor_col)
                            2'd0: selected_value <= 4'd0; // 0
                            2'd1: selected_value <= 4'd10; // . decimal
                            2'd2: selected_value <= 4'd11; // x backspace
                        endcase
                    end
                endcase
            end

            debounce_C <= 200;
        end

        // Update previous button states
        prev_btnU <= btnU;
        prev_btnD <= btnD;
        prev_btnL <= btnL;
        prev_btnR <= btnR;
        prev_btnC <= btnC;
    end
endmodule
