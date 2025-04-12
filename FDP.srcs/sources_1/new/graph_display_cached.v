`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2025 16:24:33
// Design Name: 
// Module Name: graph_display_cached
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


module graph_display_cached(
    input clk, //6p25MHz clock
    input use_mouse,
    input clk_100MHz,
    input btnU, btnD, btnL, btnR, btnC,
    input [12:0] pixel_index,
    input signed [31:0] coeff_a, coeff_b, coeff_c, coeff_d,
    input [11:0] curr_x, curr_y,
    input [3:0] zoom_level,
    input rst,
    input pan_zoom_toggle,
    input [3:0] zpos, 
    input new_event,
    input is_pan_mouse,
    input mouse_left, mouse_right, mouse_middle,
    input [31:0] colour,
    input is_graphing_mode,
    input is_integrate,
    input signed [31:0] integration_lower_bound,
    input signed [31:0] integration_upper_bound,
    output reg [15:0] oled_data,
    input is_integral_complete_outgoing
    );

    
    // Constants
    parameter SCREEN_WIDTH = 96;
    parameter SCREEN_HEIGHT = 64;
    parameter FP_SHIFT = 16;
    parameter COLOR_AXIS = 16'h0000;      // Black for axes
    parameter COLOR_GRID = 16'h7777;      // Light gray for grid
    parameter COLOR_BG = 16'hFFFF;        // White for background
    parameter COLOR_FILL = 16'h001F;      // Area fill for integration

    // Pixel position
    wire [6:0] x_pos = pixel_index % SCREEN_WIDTH;
    wire [5:0] y_pos = SCREEN_HEIGHT - (pixel_index / SCREEN_WIDTH);

    // Cache for computed values
    reg signed [47:0] y_cache[0:SCREEN_WIDTH-1];
    reg [SCREEN_WIDTH-1:0] valid_cache = 0; // Bit mask for valid cache entries

    // Previous graph parameters for change detection
    reg signed [15:0] prev_pan_x = 0;
    reg signed [15:0] prev_pan_y = 0;
    reg [3:0] prev_zoom_level_x = 0;
    reg [3:0] prev_zoom_level_y = 0;
    reg signed [31:0] prev_coeff_a = 0;
    reg signed [31:0] prev_coeff_b = 0;
    reg signed [31:0] prev_coeff_c = 0;
    reg signed [31:0] prev_coeff_d = 0;
    // Overall flag that tells whether the cache is valid, valid_cache is at entry level
    reg cache_valid = 0;

    // Pan/zoom control
    wire signed [15:0] pan_offset_x;
    wire signed [15:0] pan_offset_y;
    wire signed [4:0] zoom_level_x;
    wire signed [4:0] zoom_level_y;
    reg is_pan = 1;
    reg [47:0] tolerance;

    // Control state machine
    reg [2:0] computation_state = 0;
    parameter IDLE = 0;
    parameter CHECK_PARAMS = 1;
    parameter COMPUTE_VALUES = 2;
    parameter WAIT_COMPUTATION = 3;
    parameter CACHE_UPDATED = 4;

    // Computation control variables
    // Current Index will span from 0 to 95 (SCREEN_WIDTH - 1)
    reg [6:0] current_x_index = 0;
    reg compute_request = 0;
    wire compute_complete;
    wire signed [47:0] computed_y;

    // Connect polynomial computation module
    polynomial_computation graph_compute(
        .clk(clk),
        .requires_computation(compute_request),
        .x_value(($signed((current_x_index - (SCREEN_WIDTH >> 1)) << FP_SHIFT) >>> zoom_level_x) + 
                 (pan_offset_x <<< FP_SHIFT)),
        .coeff_a(coeff_a),
        .coeff_b(coeff_b),
        .coeff_c(coeff_c),
        .coeff_d(coeff_d),
        .y_value(computed_y),
        .computation_complete(compute_complete)
    );

    // Connect pan_graph module for pan and zoom functionality
    pan_graph panning_unit(
        .clk(clk),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .btnC(btnC),
        .pan_zoom_toggle(pan_zoom_toggle),
        .is_graphing_mode(is_graphing_mode),
        .pan_offset_x(pan_offset_x),
        .pan_offset_y(pan_offset_y),
        .zoom_level_x(zoom_level_x),
        .zoom_level_y(zoom_level_y)
    );

    // Main control state machine, updates cache of y values when user view changes
    always @(posedge clk) begin
        // Default: clear computation request
        compute_request <= 0;
        
        if (is_graphing_mode) begin
            case (computation_state)
                IDLE: begin
                    // Move to parameter check state
                    computation_state <= CHECK_PARAMS;
                end
                
                CHECK_PARAMS: begin
                    // Check if any parameters changed
                    if (pan_offset_x != prev_pan_x || 
                        pan_offset_y != prev_pan_y || 
                        zoom_level_x != prev_zoom_level_x ||
                        zoom_level_y != prev_zoom_level_y ||
                        coeff_a != prev_coeff_a || 
                        coeff_b != prev_coeff_b ||
                        coeff_c != prev_coeff_c || 
                        coeff_d != prev_coeff_d) 
                    begin
                        // Parameters changed, invalidate cache
                        valid_cache <= 0;
                        cache_valid <= 0;
                        
                        // Update stored parameters
                        prev_pan_x <= pan_offset_x;
                        prev_pan_y <= pan_offset_y;
                        prev_zoom_level_x <= zoom_level_x;
                        prev_zoom_level_y <= zoom_level_y;
                        prev_coeff_a <= coeff_a;
                        prev_coeff_b <= coeff_b;
                        prev_coeff_c <= coeff_c;
                        prev_coeff_d <= coeff_d;
                        
                        // Start computation process
                        current_x_index <= 0;
                        computation_state <= COMPUTE_VALUES;
                        
                    end
                    else if (!cache_valid) begin
                        // Cache is invalid but parameters haven't changed, continue computation
                        computation_state <= COMPUTE_VALUES;
                    end
                    else begin
                        // Stay in CHECK_PARAMS state, cache is valid
                    end
                end
                
                COMPUTE_VALUES: begin
                    // Request computation for current x index
                    compute_request <= 1;
                    computation_state <= WAIT_COMPUTATION;
                end
                
                WAIT_COMPUTATION: begin
                    // Wait for computation to complete
                    if (compute_complete) begin
                        // Store result in cache
                        y_cache[current_x_index] <= computed_y;
                        valid_cache[current_x_index] <= 1;
                        
                        // Check if we've computed all points
                        if (current_x_index == SCREEN_WIDTH - 1) begin
                            cache_valid <= 1;
                            computation_state <= CACHE_UPDATED;
                        end
                        else begin
                            // Move to next x position
                            current_x_index <= current_x_index + 1;
                            computation_state <= COMPUTE_VALUES;
                        end
                    end
                    else begin
                        // Keep computation request high
                        compute_request <= 1;
                    end
                end
                
                CACHE_UPDATED: begin
                    // Cache is fully updated, return to parameter checking
                    computation_state <= CHECK_PARAMS;
                end
            endcase
        end
    end

    reg signed [31:0] x_math_pos;
    reg signed [31:0] y_math_pos;
    reg signed [47:0] curr_y_val;
    reg signed [47:0] prev_y_val;
    reg is_overflow;

    // Rendering logic - happens on every clock cycle based on cached values
    always @(posedge clk) begin
        if (is_graphing_mode) begin
            // Default background
            oled_data <= COLOR_BG;
            
            // Calculate transformed x position for grid
            x_math_pos = ( $signed((x_pos - (SCREEN_WIDTH >> 1)) << FP_SHIFT) >>> zoom_level_x) + 
                                           (pan_offset_x <<< FP_SHIFT);
            y_math_pos = ( $signed((y_pos - (SCREEN_HEIGHT >> 1)) << FP_SHIFT) >>> zoom_level_y) + 
                                           (pan_offset_y <<< FP_SHIFT);
            tolerance = (1 << (FP_SHIFT-1)) >>> zoom_level_y;
            
            // Draw grid lines
            if ((x_math_pos % (10 << FP_SHIFT)) == 0 || (y_math_pos % (10 << FP_SHIFT)) == 0) begin
                oled_data <= COLOR_GRID;
            end
            
            // Draw axes
            if (x_math_pos == 0 || y_math_pos == 0) begin
                oled_data <= COLOR_AXIS;
            end
            
            // Draw graph lines only if cache is valid and current pixel has valid neighbors
            if (cache_valid && x_pos > 0 && x_pos < SCREEN_WIDTH) begin
                is_overflow = 0;
                // Get current and previous y values from cache
                curr_y_val = y_cache[x_pos];
                prev_y_val = y_cache[x_pos-1];

                if (curr_y_val > 48'sh00007FFF0000|| curr_y_val < -48'sh000080000000) begin
                    is_overflow = 1;
                end

                // Check if the line crosses or comes close to the current y_math_pos
                if (
                    (
                        (curr_y_val >= y_math_pos && prev_y_val <= y_math_pos) || 
                        (curr_y_val <= y_math_pos && prev_y_val >= y_math_pos)
                    ) || 
                    (
                        (curr_y_val >= (y_math_pos - tolerance)) && 
                        (curr_y_val <  (y_math_pos + tolerance))
                    )
                )
                begin
                    if (!is_overflow) begin
                        oled_data <= colour;
                    end
                end
                
                // Fill area for integration
//                if (is_in_bounds && y_pos >= (SCREEN_HEIGHT >> 1) && 
//                    y_pos <= curr_y_screen && curr_y_screen >= (SCREEN_HEIGHT >> 1)) 
//                begin
//                    oled_data <= COLOR_FILL;
//                end

                if ( 
                    (
                        ((y_math_pos < curr_y_val ) && (y_math_pos >= 0))
                        ||
                        ((y_math_pos > curr_y_val ) && (y_math_pos <= 0))
                    )
                    &&
                    (
                        (x_math_pos >= integration_lower_bound)
                        &&
                        (x_math_pos <= integration_upper_bound)
                    )
                    &&
                    is_integral_complete_outgoing
                ) begin
                    oled_data <= COLOR_FILL;
                end


            end
        end
    end

    // Initialize y_cache
    integer i;
    initial begin
        for (i = 0; i < SCREEN_WIDTH; i = i + 1) begin
            y_cache[i] = 0;
        end
        valid_cache = 0;
        cache_valid = 0;
    end


endmodule
