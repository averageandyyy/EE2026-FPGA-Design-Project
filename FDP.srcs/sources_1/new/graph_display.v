`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2025 13:06:01
// Design Name: 
// Module Name: graph_display
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


module graph_display (
    input clk,
    input btnU, btnD, btnL, btnR, btnC,
    input [12:0] pixel_index,
    //input [3:0] zoom_level,    // KIV for daniel, for mouse
    input signed [31:0] coeff_1, // [31:16] for integer, [15:0] for fractions
    input signed [31:0] coeff_2,
    input signed [31:0] coeff_3,
    input signed [31:0] coeff_4,
    input [31:0] colour,
    input is_graphing_mode,
    input is_integrate,
    output reg [15:0] oled_data, // OLED pixel data (RGB 565 format)
    output reg oled_valid,
    output reg [15:0] led,
    output [7:0] seg,
    output [3:0] an
);

    // Parameters for screen size
    parameter SCREEN_WIDTH = 96;
    parameter SCREEN_HEIGHT = 64;
    parameter FP_SHIFT = 16;
    
    
    wire signed [15:0]pan_offset_x;
    wire signed [15:0]pan_offset_y;
    wire [15:0]zoom_level_x;
    wire [15:0]zoom_level_y;
    
    pan_graph panning_unit (
        .basys_clk(clk),
        .btnU(btnU), 
        .btnD(btnD), 
        .btnL(btnL), 
        .btnR(btnR),
        .is_pan(is_pan),
        .pan_offset_x(pan_offset_x), 
        .pan_offset_y(pan_offset_y),
        .zoom_level_x(zoom_level_x),
        .zoom_level_y(zoom_level_y)
        );
        

    // Coordinates
    wire [6:0]x_pos;
    wire [5:0]y_pos;
    assign x_pos = pixel_index % SCREEN_WIDTH;
    assign y_pos = SCREEN_HEIGHT - (pixel_index / SCREEN_WIDTH);
    
    reg signed [31:0] x_coord = 0;
    reg signed [31:0] y_coord = 0;
    
    reg result = 0;
    reg zoom = 0;
    
    reg [5:0] space = {6{1'b1}};
    wire text_flag = 0;
    wire [15:0] text_colour = 16'b00000_000000_11111;
    
    // Instantiate number sprites at different positions
    
    string_renderer coefficients (
        .clk(clk),
        .pixel_index(pixel_index),
        .word({  {2'b00}, coeff_4, space, {2'b00}, coeff_3, space, {2'b00}, coeff_2, space, {2'b00}, coeff_1, space  }),
        .start_x(20), // X position
        .start_y(14), // Y position
        .colour(16'h0000), // Colour (e.g., red)
        .oled_data(text_colour),
        .active_pixel(text_flag)
    );
    
    reg signed [63:0]y_plot = 0; // Holds value of equation
    reg signed [63:0]y_plot_next = 0; // Hold next value of equation
    reg signed [31:0]x_coord_next = 0;
    
    reg is_pan = 1;
    reg prev_btnC = 0;
    reg x_intg_limit = 96; // to use for animation
    
    reg signed [127:0] temp_cubic;
    reg signed [95:0] temp_quad;
    reg signed [63:0] temp_linear;
    reg overflow_flag = 0;
    
    reg signed [127:0] temp_cubic_next; 
    
    render_segments integrate_sign(.clk(clk), .is_integrate(is_integrate), .seg(seg), .an(an));
    
    
    // Initialize
    always @(posedge clk) begin
        if (is_graphing_mode) begin
            
        
            if (prev_btnC & ~btnC) begin
                is_pan = ~is_pan;
            end  
            
            oled_data = 16'hFFFF;
            oled_valid = 1;
       
            if (y_pos > 0 && y_pos < 63) begin      
                                
                x_coord = (((x_pos - (SCREEN_WIDTH / 2)) * (65536 / zoom_level_x)) + (pan_offset_x * 65536));
                y_coord = (((y_pos - (SCREEN_HEIGHT / 2)) * (65536 / zoom_level_y)) + (pan_offset_y * 65536)); 
                x_coord_next = (((x_pos - (SCREEN_WIDTH / 2) + 1) * (65536 / zoom_level_x)) + (pan_offset_x * 65536));
//                x_coord = (x_pos / zoom_level_x) - pan_offset_x;
//                y_coord = (y_pos  / zoom_level_y) - pan_offset_y;
                
                // Simple grid rendering (every 10 pixels vertical & horizontal lines)
                if (
                    ( (x_coord % (16'd10 <<< FP_SHIFT )) == 0 ) 
                    || 
                    ( (y_coord % (16'd10 <<< FP_SHIFT )) == 0 )
                ) begin
                    oled_data = 16'h7777; // grey grid lines
                end
                //Render x and y axis
                if ((x_coord == 0) || (y_coord == 0)) begin
                    oled_data = 16'h0000; // black axis lines
                end
                overflow_flag = 0; // Reset for each pixel
                
                temp_cubic = coeff_1 * x_coord * x_coord * x_coord;
                temp_quad  = (coeff_2 * x_coord * x_coord);
                temp_linear = (coeff_3 * x_coord);
                
                temp_cubic_next = coeff_1 * x_coord_next * x_coord_next * x_coord_next;
                
                if (
                    (temp_cubic >>> (FP_SHIFT*3)) > (32767<<<FP_SHIFT) || (temp_cubic >>> (FP_SHIFT*3)) < (-32768<<<FP_SHIFT) 
                    ||
                    (temp_quad >>> (FP_SHIFT*2)) > (32767<<<FP_SHIFT) || (temp_quad >>> (FP_SHIFT*2)) < (-32768<<<FP_SHIFT)
                    ||
                    (temp_linear >>> (FP_SHIFT)) >  (32767<<<FP_SHIFT) || (temp_linear >>> (FP_SHIFT)) < (-32768<<<FP_SHIFT)
                    ) begin
                    overflow_flag = 1;  
                end
                
                temp_cubic = temp_cubic >>> 48; // Ensure 16.16 output
                temp_quad  = temp_quad >>> 32;
                temp_linear = temp_linear >>> 16;
                
                y_plot = temp_cubic + temp_quad + temp_linear + coeff_4;
                
                if ( 
                    ( y_plot > (32767<<<FP_SHIFT) ) 
                    || 
                    ( y_plot < (-32768<<<FP_SHIFT) ) 
                    )  begin
                    overflow_flag = 1;
                end
                
                temp_cubic = coeff_1 * x_coord_next * x_coord_next * x_coord_next;
                temp_quad  = (coeff_2 * x_coord_next * x_coord_next);
                temp_linear = (coeff_3 * x_coord_next);
                
                if (
                    (temp_cubic >>> (FP_SHIFT*3)) > (32767<<<FP_SHIFT) || (temp_cubic >>> (FP_SHIFT*3)) < (-32768<<<FP_SHIFT) 
                    ||
                    (temp_quad >>> (FP_SHIFT*2)) > (32767<<<FP_SHIFT) || (temp_quad >>> (FP_SHIFT*2)) < (-32768<<<FP_SHIFT)
                    ||
                    (temp_linear >>> (FP_SHIFT)) >  (32767<<<FP_SHIFT) || (temp_linear >>> (FP_SHIFT)) < (-32768<<<FP_SHIFT)
                    ) begin
                    overflow_flag = 1;  
                end
                
                temp_cubic = temp_cubic >>> 48; // Ensure 16.16 output
                temp_quad  = temp_quad >>> 32;
                temp_linear = temp_linear >>> 16;
                
                y_plot_next = temp_cubic + temp_quad + temp_linear + coeff_4;
                
                if ( 
                    ( y_plot_next > (32767<<<FP_SHIFT) ) 
                    || 
                    ( y_plot_next < (-32768<<<FP_SHIFT) ) 
                    )  begin
                    overflow_flag = 1;
                end
                
               if (~overflow_flag) begin
                   if (y_plot_next > y_plot) begin
                        if ((y_coord >= y_plot) && (y_coord < y_plot_next)) begin
                            oled_data = colour;
                        end
                    end else if (y_plot_next < y_plot) begin
                        if ((y_coord >= y_plot_next) && (y_coord < y_plot)) begin
                            oled_data = colour;
                        end
                    end else if (y_coord == y_plot) begin
                        oled_data = colour;
                    end
                
                    if (is_integrate) begin
                        if (
                            ( (y_coord <= y_plot) && (y_coord > 0) )
                            ||
                            ( (y_coord >= y_plot) && (y_coord < 0) )
                            ) begin
                            oled_data = colour;
                        end
                    end
                end
                
            end
            
            prev_btnC <= btnC;
            led[15] = is_pan;
            led[0] = overflow_flag;
        end
    end
    
endmodule
