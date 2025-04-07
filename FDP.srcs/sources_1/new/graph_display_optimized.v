`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.04.2025 11:26:47
// Design Name: 
// Module Name: graph_display_optimized
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


module graph_display_optimized(
    input clk,
    input btnU, btnD, btnL, btnR, btnC,
    input [12:0] pixel_index,
    input signed [31:0] coeff_1, // [31:16] for integer, [15:0] for fractions
    input signed [31:0] coeff_2,
    input signed [31:0] coeff_3,
    input signed [31:0] coeff_4,
    input [11:0] curr_x,
    input [11:0] curr_y,
    input [3:0] zoom_level,
    input mouse_left,
    input new_event,
    input mouse_middle,
    input mouse_right,
    input [31:0] colour,
    input is_graphing_mode,
    input is_integrate,
    input signed [31:0] integration_lower_bound, // to be implemented lat
    input signed [31:0] integration_upper_bound,
    output reg [15:0] oled_data,
    output reg oled_valid,
    output [15:0] led,
    output [7:0] seg,
    output [3:0] an
    );

// Parameters for screen size
    parameter SCREEN_WIDTH = 96;
    parameter SCREEN_HEIGHT = 64;
    parameter FP_SHIFT = 16;
    
    // Panning and zooming signals
    wire signed [15:0] pan_offset_x;
    wire signed [15:0] pan_offset_y;
    wire [15:0] zoom_level_x;
    wire [15:0] zoom_level_y;
    reg is_pan = 1;
    reg prev_btnC = 0;
    
    // Pixel tracking
    wire [6:0] x_pos;
    wire [5:0] y_pos;
    reg [12:0] prev_pixel_index = 0;
    
    // Extract x and y from pixel index
    assign x_pos = pixel_index % SCREEN_WIDTH;
    assign y_pos = SCREEN_HEIGHT - (pixel_index / SCREEN_WIDTH);
    
    // Sequential calculation state machine
    reg [3:0] calc_state = 0;
    parameter IDLE = 4'd0;
    parameter TRANSFORM_X = 4'd1;
    parameter COMPUTE_X_SQUARED = 4'd2;
    parameter COMPUTE_X_CUBED = 4'd3;
    parameter HORNER_STEP_1 = 4'd4;
    parameter HORNER_STEP_2 = 4'd5;
    parameter HORNER_STEP_3 = 4'd6;
    parameter EVALUATE_POINT = 4'd7;
    parameter RENDER_PIXEL = 4'd8;
    
    // Computation registers
    reg signed [31:0] x_coord;
    reg signed [31:0] y_coord;
    reg signed [31:0] x_val;
    reg signed [31:0] x_squared;
    reg signed [31:0] x_cubed;
    reg signed [31:0] horner_result;
    reg signed [63:0] temp_mult;
    reg overflow_flag = 0;
    reg has_evaluated = 0;

    assign led[12] = has_evaluated;
    
    // Line drawing storage
    reg signed [31:0] prev_y_plot[0:SCREEN_WIDTH-1];
    reg signed [31:0] y_plot;
    
    // Integration bounds in screen coordinates
    reg signed [31:0] lower_px, upper_px;
    reg is_in_bounds;
    
    // Connect pan_graph module
    pan_graph panning_unit (
        .basys_clk(clk),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .btnC(btnC),
        .is_pan(is_pan),
        .mouse_x(curr_x),
        .mouse_y(curr_y),
        .zpos(zoom_level),
        .new_event(new_event),
        .left(mouse_left),
        .right(mouse_right),
        .pan_offset_x(pan_offset_x),
        .pan_offset_y(pan_offset_y),
        .zoom_level_x(zoom_level_x),
        .zoom_level_y(zoom_level_y)
        // .led(led)
    );
    
    // Connect 7-segment display for integration mode
    render_segments integrate_sign(
        .clk(clk),
        .is_integrate(is_integrate),
        .seg(seg),
        .an(an)
    );

    // Main computation state machine
    always @(posedge clk) begin
        // Reset evaluation flag when moving to new pixel
        if (pixel_index != prev_pixel_index) begin
            has_evaluated <= 0;
            prev_pixel_index <= pixel_index;
        end
        
        if (is_graphing_mode) begin
            // Switch between pan and zoom
            if (prev_btnC & ~btnC) begin
                is_pan = ~is_pan;
            end 

            x_coord <= (((x_pos - (SCREEN_WIDTH >> 1)) << FP_SHIFT) / zoom_level_x) + (pan_offset_x << FP_SHIFT);
            y_coord <= (((y_pos - (SCREEN_HEIGHT >> 1)) << FP_SHIFT) / zoom_level_y) + (pan_offset_y << FP_SHIFT);

            // Calculate integration bounds in screen coordinates
            // if (is_integrate) begin
                // // Transform integration bounds to pixel coordinates
                // lower_px <= (((integration_lower_bound - (pan_offset_x << FP_SHIFT)) * zoom_level_x) >> FP_SHIFT) + (SCREEN_WIDTH / 2);
                // upper_px <= (((integration_upper_bound - (pan_offset_x << FP_SHIFT)) * zoom_level_x) >> FP_SHIFT) + (SCREEN_WIDTH / 2);
            // end
        
            case (calc_state)
                IDLE: begin
                    // Check if we need to process the current pixel
                    if (!has_evaluated && y_pos > 0 && y_pos < SCREEN_HEIGHT - 1) begin
                        overflow_flag <= 0;
                        calc_state <= COMPUTE_X_SQUARED;
                    end
                end
                
                COMPUTE_X_SQUARED: begin
                    // Calculate x^2 using shared multiplier
                    temp_mult <= x_coord * x_coord;
                    calc_state <= COMPUTE_X_CUBED;
                end
                
                COMPUTE_X_CUBED: begin
                    // Store x^2 and calculate x^3
                    x_squared <= temp_mult >>> FP_SHIFT;
                    temp_mult <= (temp_mult >>> FP_SHIFT) * x_coord;
                    // calc_state <= HORNER_STEP_1;
                    calc_state <= HORNER_STEP_3;
                end
                
                HORNER_STEP_1: begin
                    // Store x^3 and begin Horner's method with coeff_1*x^3
                    x_cubed <= temp_mult >>> FP_SHIFT;
                    temp_mult <= coeff_1 * (temp_mult >>> FP_SHIFT);
                    // calc_state <= HORNER_STEP_2;
                    calc_state <= HORNER_STEP_3;
                end
                
                // HORNER_STEP_2: begin
                    // // Store a*x^3 and add b*x^2
                    // horner_result <= temp_mult >>> FP_SHIFT;
                    // temp_mult <= coeff_2 * x_squared;
                    // calc_state <= HORNER_STEP_3;
                // end
                
                HORNER_STEP_3: begin
                    // Add b*x^2 to result and calculate c*x
                    horner_result <= (temp_mult >>> FP_SHIFT);
                    temp_mult <= coeff_3 * x_coord;
                    calc_state <= EVALUATE_POINT;
                end
                
                EVALUATE_POINT: begin
                    // Add c*x + d to get final result
                    horner_result <= (temp_mult >>> FP_SHIFT) + coeff_4;
                    
                    // Check for overflow
                    if ((horner_result > (32767 <<< FP_SHIFT)) || (horner_result < (-32768 <<< FP_SHIFT))) begin
                        overflow_flag <= 1;
                    end
                    
                    calc_state <= RENDER_PIXEL;
                end
                
                RENDER_PIXEL: begin
                    // Store y result and mark as evaluated
                    y_plot <= horner_result;
                    prev_y_plot[x_pos] <= horner_result;
                    has_evaluated <= 1;
                    calc_state <= IDLE;
                end
            endcase

            prev_btnC <= btnC;
        end
    end
    
    // Check if current pixel is inside integration bounds
    always @ (*) begin
        is_in_bounds = 0;
        if (is_integrate) begin
            // Handle both cases: lower_px < upper_px and lower_px > upper_px
            is_in_bounds = (x_pos >= lower_px && x_pos <= upper_px) || (x_pos <= lower_px && x_pos >= upper_px);
        end
    end
    
    // Rendering logic - now separate from calculation
    always @(posedge clk) begin
        if (is_graphing_mode) begin
            oled_data = 16'hFFFF;  // Default white background
            oled_valid = 1;
            
            // Handle grid rendering
            if (y_pos > 0 && y_pos < SCREEN_HEIGHT - 1) begin
                // Transform current position to math coordinates for grid lines
                x_val = (((x_pos - (SCREEN_WIDTH >> 1)) << FP_SHIFT) / zoom_level_x) + (pan_offset_x << FP_SHIFT);
                
                // Grid lines
                if ((x_val % (10 << FP_SHIFT)) == 0 || (y_coord % (10 << FP_SHIFT)) == 0) begin
                    oled_data = 16'h7777; // Light grey grid lines
                end
                
                // Axes
                if (x_val == 0 || y_coord == 0) begin
                    oled_data = 16'h0000; // Black axes
                end
                
                // Draw graph if this pixel has been evaluated
                if (has_evaluated && !overflow_flag) begin
                    // Improved line drawing algorithm
                    if (x_pos > 0) begin
                        // Check if we cross the current y
                        if ((y_plot >= y_coord && prev_y_plot[x_pos-1] < y_coord) || 
                            (y_plot <= y_coord && prev_y_plot[x_pos-1] > y_coord)) begin
                            oled_data = colour;
                        end 
                        else if (y_plot == y_coord) begin
                            oled_data = colour;
                        end
                    end
                    
                    // Fill area under curve for integration
                    if (is_integrate && is_in_bounds) begin
                        if (y_plot >= (y_coord << FP_SHIFT) && y_coord <= (SCREEN_HEIGHT >> 1)) begin
                            // Only fill area below curve and above x-axis
                            oled_data = 16'h841F; // Semi-transparent fill color
                        end
                    end
                end
            end
        end
    end


endmodule
