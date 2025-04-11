module arithmetic_cursor_controller(
    input clk,
    input clk_100MHz,
    input clk_6p25MHz,
    input mouse_left,
    input use_mouse,
    input [11:0]xpos,
    input [11:0]ypos,
    input reset,
    input btnC,
    input btnU,
    input btnD,
    input btnL,
    input btnR,
    input is_operand_mode,
    output reg [1:0]cursor_row_keypad = 0,
    output reg [2:0]cursor_col_keypad = 0,
    output reg [1:0]cursor_row_operand = 0,
    output reg [1:0]cursor_col_operand = 0,
    output reg keypad_btn_pressed = 0,
    output reg [3:0]keypad_selected_value = 0,
    output reg operand_btn_pressed = 0,
    output reg [1:0]operand_selected_value = 0
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
                //debouncing for left mouse button
    parameter DEBOUNCE_DELAY = 2000000;
    reg [21:0] ctr;    // Counter for debounce delay (needs enough bits)
    reg debounced;         // Stores the debounced state
    initial begin
        ctr   = 0;
        debounced = 1'b0;
    end
    always @(posedge clk_100MHz) begin
        if (mouse_left == debounced) 
            ctr <= 0;
        else begin
            ctr <= ctr + 1;
        if (ctr >= DEBOUNCE_DELAY) debounced <= mouse_left; 
        end
    end
    reg mouse_left_prev;
    initial begin mouse_left_prev = 1'b0; end
    wire [6:0] mouse_xpos, mouse_ypos;

//get current coordinates of the mouse
    mouse_coordinate_extractor coord_extr(
    clk_6p25MHz, //6p25MHz clock
    xpos,    // 12-bit mouse x position
    ypos,    // 12-bit mouse y position
    mouse_xpos, mouse_ypos);
    //end of getting current coordinates of the mouse


    // Waiting counter
    reg [8:0] counter = 9'd500;

    // Flag to track if on the checkmark
    wire on_checkmark = (cursor_col_keypad == 3'd3 && !is_operand_mode);

    // Button handling loop
    always @ (posedge clk) begin
        if (reset) begin
            // Reset all state variables to initial values
            cursor_row_keypad <= 0;
            cursor_col_keypad <= 0;
            cursor_row_operand <= 0;
            cursor_col_operand <= 0;
            keypad_btn_pressed <= 0;
            keypad_selected_value <= 0;
            operand_btn_pressed <= 0;
            operand_selected_value <= 0;
            
            // Reset debounce counters and button states
            prev_btnC <= 0;
            prev_btnU <= 0;
            prev_btnD <= 0;
            prev_btnL <= 0;
            prev_btnR <= 0;
            debounce_C <= 0;
            debounce_U <= 0;
            debounce_D <= 0;
            debounce_L <= 0;
            debounce_R <= 0;
            counter <= 500;
        end
        else begin
            // Reset button pressed signal each cycle
            keypad_btn_pressed <= 0;
            operand_btn_pressed <= 0;
        
            // Decrement debounce counters if active
            if (debounce_U > 0) debounce_U <= debounce_U - 1;
            if (debounce_D > 0) debounce_D <= debounce_D - 1;
            if (debounce_L > 0) debounce_L <= debounce_L - 1;
            if (debounce_R > 0) debounce_R <= debounce_R - 1;
            if (debounce_C > 0) debounce_C <= debounce_C - 1;

            if (!is_operand_mode) begin
                if (counter == 0) begin
                    if (use_mouse && mouse_xpos >= 0 && mouse_xpos <= 23 && mouse_ypos >= 0 && mouse_ypos <= 15) begin
                        cursor_row_keypad <= 0;
                        cursor_col_keypad <= 0;
                    end
                    else if (use_mouse && mouse_xpos >= 0 && mouse_xpos <= 23 && mouse_ypos >= 16 && mouse_ypos <= 31) begin
                        cursor_row_keypad <= 1;
                        cursor_col_keypad <= 0;
                    end
                    else if (use_mouse && mouse_xpos >= 0 && mouse_xpos <= 23 && mouse_ypos >= 32 && mouse_ypos <= 47) begin
                        cursor_row_keypad <= 2;
                        cursor_col_keypad <= 0;
                    end
                    else if (use_mouse && mouse_xpos >= 0 && mouse_xpos <= 23 && mouse_ypos >= 48 && mouse_ypos <= 63) begin
                        cursor_row_keypad <= 3;
                        cursor_col_keypad <= 0;
                    end
                    else if (use_mouse && mouse_xpos >= 24 && mouse_xpos <= 47 && mouse_ypos >= 0 && mouse_ypos <= 15) begin
                        cursor_row_keypad <= 0;
                        cursor_col_keypad <= 1;
                    end
                    else if (use_mouse && mouse_xpos >= 24 && mouse_xpos <= 47 && mouse_ypos >= 16 && mouse_ypos <= 31) begin
                        cursor_row_keypad <= 1;
                        cursor_col_keypad <= 1;
                    end
                    else if (use_mouse && mouse_xpos >= 24 && mouse_xpos <= 47 && mouse_ypos >= 32 && mouse_ypos <= 47) begin
                        cursor_row_keypad <= 2;
                        cursor_col_keypad <= 1;
                    end
                    else if (use_mouse && mouse_xpos >= 24 && mouse_xpos <= 47 && mouse_ypos >= 48 && mouse_ypos <= 63) begin
                        cursor_row_keypad <= 3;
                        cursor_col_keypad <= 1;
                    end
                    else if (use_mouse && mouse_xpos >= 48 && mouse_xpos <= 71 && mouse_ypos >= 0 && mouse_ypos <= 15) begin
                        cursor_row_keypad <= 0;
                        cursor_col_keypad <= 2;
                    end
                    else if (use_mouse && mouse_xpos >= 48 && mouse_xpos <= 71 && mouse_ypos >= 16 && mouse_ypos <= 31) begin
                        cursor_row_keypad <= 1;
                        cursor_col_keypad <= 2;
                    end
                    else if (use_mouse && mouse_xpos >= 48 && mouse_xpos <= 71 && mouse_ypos >= 32 && mouse_ypos <= 47) begin
                        cursor_row_keypad <= 2;
                        cursor_col_keypad <= 2;
                    end
                    else if (use_mouse && mouse_xpos >= 48 && mouse_xpos <= 71 && mouse_ypos >= 48 && mouse_ypos <= 63) begin
                        cursor_row_keypad <= 3;
                        cursor_col_keypad <= 2;
                    end
                    else if (use_mouse) begin //this is the checkmark side
                        cursor_col_keypad <= 3;
                    end
                    // Up button processing
                    if (btnU && !prev_btnU && debounce_U == 0) begin
                        if (cursor_row_keypad > 0 && !on_checkmark) begin
                            cursor_row_keypad <= cursor_row_keypad - 1;
                        end
                        debounce_U <= 200;
                    end

                    // Down
                    if (btnD && !prev_btnD && debounce_D == 0) begin
                        if (cursor_row_keypad < 3 && !on_checkmark) begin
                            cursor_row_keypad <= cursor_row_keypad + 1;
                        end
                        debounce_D <= 200;
                    end

                    // Left
                    if (btnL && !prev_btnL && debounce_L == 0) begin
                        if (on_checkmark) begin
                            // Moving left from checkmark goes to the main keypad
                            cursor_col_keypad <= 3'd2;
                        end else if (cursor_col_keypad > 0) begin
                            cursor_col_keypad <= cursor_col_keypad - 1;
                        end
                        debounce_L <= 200;
                    end

                    // Right
                    if (btnR && !prev_btnR && debounce_R == 0) begin
                        if (!on_checkmark && cursor_col_keypad < 2) begin
                            cursor_col_keypad <= cursor_col_keypad + 1;
                        end else if (!on_checkmark && cursor_col_keypad == 2) begin
                            cursor_col_keypad <= 3'd3;  // Go to checkmark column
                        end
                        debounce_R <= 200;
                    end

                    // Center (Selection)
                    if (btnC && !prev_btnC && debounce_C == 0 || (use_mouse && debounced && !mouse_left_prev)) begin
                        keypad_btn_pressed <= 1;
                        counter <= 500;
                        if (on_checkmark) begin
                            // Checkmark selected
                            keypad_selected_value <= 4'd12;  // Special value for checkmark
                        end else begin
                            // Determining selected value based on cursor position in main keypad
                            case(cursor_row_keypad)
                                2'd0: keypad_selected_value <= cursor_col_keypad + 4'd7; // 7, 8, 9
                                2'd1: keypad_selected_value <= cursor_col_keypad + 4'd4; // 4, 5, 6
                                2'd2: keypad_selected_value <= cursor_col_keypad + 4'd1; // 1, 2, 3
                                2'd3: begin
                                    case(cursor_col_keypad)
                                        2'd0: keypad_selected_value <= 4'd0; // 0
                                        2'd1: keypad_selected_value <= 4'd10; // . decimal
                                        2'd2: keypad_selected_value <= 4'd11; // x backspace
                                    endcase
                                end
                            endcase
                        end

                        debounce_C <= 200;
                    end
                end
                else begin
                    counter <= counter -1;
                end
            end
            else begin
                // OPERAND MODE
                
                if (use_mouse && mouse_xpos >= 0 && mouse_xpos <= 47 && mouse_ypos <= 31 && mouse_ypos >= 0) begin //for +
                    cursor_row_operand <= 0;
                    cursor_col_operand <= 0;
                end
                else if (use_mouse && mouse_xpos >= 48 && mouse_xpos <= 95 && mouse_ypos <= 31 && mouse_ypos >= 0) begin //for -
                    cursor_row_operand <= 0;
                    cursor_col_operand <= 1;
                end
                else if (use_mouse && mouse_xpos >= 0 && mouse_xpos <= 47 && mouse_ypos <= 63 && mouse_ypos >= 32) begin //for x
                    cursor_row_operand <= 1;
                    cursor_col_operand <= 0;
                end
                else if (use_mouse) begin //for divide
                    cursor_row_operand <= 1;
                    cursor_col_operand <= 1;
                end
                
                // Up button handling
                if (btnU && !prev_btnU && debounce_U == 0) begin
                    if (cursor_row_operand > 0) begin
                        cursor_row_operand <= cursor_row_operand - 1;
                    end
                    debounce_U <= 200;
                end
            
                // Down button handling
                if (btnD && !prev_btnD && debounce_D == 0) begin
                    if (cursor_row_operand < 1) begin  
                        cursor_row_operand <= cursor_row_operand + 1;
                    end
                    debounce_D <= 200;
                end
            
                // Left button handling
                if (btnL && !prev_btnL && debounce_L == 0) begin
                    if (cursor_col_operand > 0) begin
                        cursor_col_operand <= cursor_col_operand - 1;
                    end
                    debounce_L <= 200;
                end
            
                // Right button handling
                if (btnR && !prev_btnR && debounce_R == 0) begin
                    if (cursor_col_operand < 1) begin  
                        cursor_col_operand <= cursor_col_operand + 1;
                    end
                    debounce_R <= 200;
                end
            
                // Center button handling (selection)
                if (btnC && !prev_btnC && debounce_C == 0 || (use_mouse && debounced && !mouse_left_prev)) begin
                    operand_btn_pressed <= 1;
                
                    // Determine selected operand based on cursor position
                    case({cursor_row_operand, cursor_col_operand})
                        4'b00_00: operand_selected_value <= 2'd0; // +
                        4'b00_01: operand_selected_value <= 2'd1; // -
                        4'b01_00: operand_selected_value <= 2'd2; // ×
                        4'b01_01: operand_selected_value <= 2'd3; // ÷
                    endcase
                
                    debounce_C <= 200;
                end
            end

        

            // Update previous button states
            prev_btnU <= btnU;
            prev_btnD <= btnD;
            prev_btnL <= btnL;
            prev_btnR <= btnR;
            prev_btnC <= btnC;
            mouse_left_prev <= debounced;
        end
    end
endmodule