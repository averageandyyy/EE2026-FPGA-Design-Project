`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2025 13:24:17
// Design Name: 
// Module Name: integral_computation
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


(* use_dsp = "yes" *) module integral_computation(
    input clk,                      
    input reset,                    
    input start_computation,        
    input signed [31:0] coeff_a,    
    input signed [31:0] coeff_b,    
    input signed [31:0] coeff_c,    
    input signed [31:0] coeff_d,   
    input signed [31:0] a_lower,   
    input signed [31:0] b_upper,    
    output reg signed [31:0] integral_result, 
    output reg is_computation_complete       
    );

    // Fixed-point format constants
    localparam FP_SHIFT = 16;
    localparam FP_ONE = 32'h00010000;  
    
    // Precomputed coefficients for division
    localparam FP_ONE_FOURTH = 32'h00004000; 
    localparam FP_ONE_THIRD = 32'h00005555;  
    localparam FP_ONE_HALF = 32'h00008000;   
    
    // State definitions
    localparam IDLE = 5'd0;
    
    // A bound calculation states
    localparam COMPUTE_A_SQUARED_START = 5'd1;
    localparam COMPUTE_A_SQUARED_FINISH = 5'd2;
    localparam COMPUTE_A_CUBED_START = 5'd3;
    localparam COMPUTE_A_CUBED_FINISH = 5'd4;
    localparam COMPUTE_A_FOURTH_START = 5'd5;
    localparam COMPUTE_A_FOURTH_FINISH = 5'd6;
    
    // B bound calculation states
    localparam COMPUTE_B_SQUARED_START = 5'd7;
    localparam COMPUTE_B_SQUARED_FINISH = 5'd8;
    localparam COMPUTE_B_CUBED_START = 5'd9;
    localparam COMPUTE_B_CUBED_FINISH = 5'd10;
    localparam COMPUTE_B_FOURTH_START = 5'd11;
    localparam COMPUTE_B_FOURTH_FINISH = 5'd12;
    
    // A term calculation states (coeff_a/4 * (b^4 - a^4))
    localparam COMPUTE_A_TERM_DIV_START = 5'd13;
    localparam COMPUTE_A_TERM_DIV_FINISH = 5'd14;
    localparam COMPUTE_A_TERM_DIFF_START = 5'd15;
    localparam COMPUTE_A_TERM_FINISH = 5'd16;
    
    // B term calculation states (coeff_b/3 * (b^3 - a^3))
    localparam COMPUTE_B_TERM_DIV_START = 5'd17;
    localparam COMPUTE_B_TERM_DIV_FINISH = 5'd18;
    localparam COMPUTE_B_TERM_DIFF_START = 5'd19;
    localparam COMPUTE_B_TERM_FINISH = 5'd20;
    
    // C term calculation states (coeff_c/2 * (b^2 - a^2))
    localparam COMPUTE_C_TERM_DIV_START = 5'd21;
    localparam COMPUTE_C_TERM_DIV_FINISH = 5'd22;
    localparam COMPUTE_C_TERM_DIFF_START = 5'd23;
    localparam COMPUTE_C_TERM_FINISH = 5'd24;
    
    // D term calculation states (coeff_d * (b - a))
    localparam COMPUTE_D_TERM_DIFF_START = 5'd25;
    localparam COMPUTE_D_TERM_FINISH = 5'd26;
    
    // Final states
    localparam FINALIZE = 5'd27;
    localparam DONE = 5'd28;
    
    // Current state
    reg [4:0] state = IDLE;
    
    // Storage for computed powers (Q16.16)
    reg signed [31:0] a_squared, a_cubed, a_fourth;
    reg signed [31:0] b_squared, b_cubed, b_fourth;
    
    // Storage for term computations (Q16.16)
    reg signed [31:0] a_term, b_term, c_term, d_term;
    reg signed [31:0] coeff_a_div_4, coeff_b_div_3, coeff_c_div_2;
    reg signed [31:0] bound_diff, a_squared_diff, a_cubed_diff, a_fourth_diff;
    
    // Temporary variables for intermediate calculations
    reg signed [63:0] temp_mult;
    
    // Main state machine
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            is_computation_complete <= 0;
            integral_result <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (start_computation) begin
                        state <= COMPUTE_A_SQUARED_START;
                        is_computation_complete <= 0;
                    end
                end
                
                // Calculate a_lower^2
                COMPUTE_A_SQUARED_START: begin
                    temp_mult <= a_lower * a_lower;
                    state <= COMPUTE_A_SQUARED_FINISH;
                end
                
                COMPUTE_A_SQUARED_FINISH: begin
                    a_squared <= temp_mult >>> FP_SHIFT;
                    state <= COMPUTE_A_CUBED_START;
                end
                
                // Calculate a_lower^3
                COMPUTE_A_CUBED_START: begin
                    temp_mult <= a_squared * a_lower;
                    state <= COMPUTE_A_CUBED_FINISH;
                end
                
                COMPUTE_A_CUBED_FINISH: begin
                    a_cubed <= temp_mult >>> FP_SHIFT;
                    state <= COMPUTE_A_FOURTH_START;
                end
                
                // Calculate a_lower^4
                COMPUTE_A_FOURTH_START: begin
                    temp_mult <= a_cubed * a_lower;
                    state <= COMPUTE_A_FOURTH_FINISH;
                end
                
                COMPUTE_A_FOURTH_FINISH: begin
                    a_fourth <= temp_mult >>> FP_SHIFT;
                    state <= COMPUTE_B_SQUARED_START;
                end
                
                // Calculate b_upper^2
                COMPUTE_B_SQUARED_START: begin
                    temp_mult <= b_upper * b_upper;
                    state <= COMPUTE_B_SQUARED_FINISH;
                end
                
                COMPUTE_B_SQUARED_FINISH: begin
                    b_squared <= temp_mult >>> FP_SHIFT;
                    state <= COMPUTE_B_CUBED_START;
                end
                
                // Calculate b_upper^3
                COMPUTE_B_CUBED_START: begin
                    temp_mult <= b_squared * b_upper;
                    state <= COMPUTE_B_CUBED_FINISH;
                end
                
                COMPUTE_B_CUBED_FINISH: begin
                    b_cubed <= temp_mult >>> FP_SHIFT;
                    state <= COMPUTE_B_FOURTH_START;
                end
                
                // Calculate b_upper^4
                COMPUTE_B_FOURTH_START: begin
                    temp_mult <= b_cubed * b_upper;
                    state <= COMPUTE_B_FOURTH_FINISH;
                end
                
                COMPUTE_B_FOURTH_FINISH: begin
                    b_fourth <= temp_mult >>> FP_SHIFT;
                    state <= COMPUTE_A_TERM_DIV_START;
                end
                
                // Calculate coeff_a/4
                COMPUTE_A_TERM_DIV_START: begin
                    temp_mult <= coeff_a * FP_ONE_FOURTH;
                    state <= COMPUTE_A_TERM_DIV_FINISH;
                end
                
                COMPUTE_A_TERM_DIV_FINISH: begin
                    coeff_a_div_4 <= temp_mult >>> FP_SHIFT;
                    a_fourth_diff <= b_fourth - a_fourth;
                    state <= COMPUTE_A_TERM_DIFF_START;
                end
                
                // Calculate (coeff_a/4)*(b^4 - a^4)
                COMPUTE_A_TERM_DIFF_START: begin
                    temp_mult <= coeff_a_div_4 * a_fourth_diff;
                    state <= COMPUTE_A_TERM_FINISH;
                end
                
                COMPUTE_A_TERM_FINISH: begin
                    a_term <= temp_mult >>> FP_SHIFT;
                    state <= COMPUTE_B_TERM_DIV_START;
                end
                
                // Calculate coeff_b/3
                COMPUTE_B_TERM_DIV_START: begin
                    temp_mult <= coeff_b * FP_ONE_THIRD;
                    state <= COMPUTE_B_TERM_DIV_FINISH;
                end
                
                COMPUTE_B_TERM_DIV_FINISH: begin
                    coeff_b_div_3 <= temp_mult >>> FP_SHIFT;
                    a_cubed_diff <= b_cubed - a_cubed;
                    state <= COMPUTE_B_TERM_DIFF_START;
                end
                
                // Calculate (coeff_b/3)*(b^3 - a^3)
                COMPUTE_B_TERM_DIFF_START: begin
                    temp_mult <= coeff_b_div_3 * a_cubed_diff;
                    state <= COMPUTE_B_TERM_FINISH;
                end
                
                COMPUTE_B_TERM_FINISH: begin
                    b_term <= temp_mult >>> FP_SHIFT;
                    state <= COMPUTE_C_TERM_DIV_START;
                end
                
                // Calculate coeff_c/2
                COMPUTE_C_TERM_DIV_START: begin
                    temp_mult <= coeff_c * FP_ONE_HALF;
                    state <= COMPUTE_C_TERM_DIV_FINISH;
                end
                
                COMPUTE_C_TERM_DIV_FINISH: begin
                    coeff_c_div_2 <= temp_mult >>> FP_SHIFT;
                    a_squared_diff <= b_squared - a_squared;
                    state <= COMPUTE_C_TERM_DIFF_START;
                end
                
                // Calculate (coeff_c/2)*(b^2 - a^2)
                COMPUTE_C_TERM_DIFF_START: begin
                    temp_mult <= coeff_c_div_2 * a_squared_diff;
                    state <= COMPUTE_C_TERM_FINISH;
                end
                
                COMPUTE_C_TERM_FINISH: begin
                    c_term <= temp_mult >>> FP_SHIFT;
                    state <= COMPUTE_D_TERM_DIFF_START;
                end
                
                // Calculate coeff_d*(b - a)
                COMPUTE_D_TERM_DIFF_START: begin
                    bound_diff <= b_upper - a_lower;
                    temp_mult <= coeff_d * (b_upper - a_lower);
                    state <= COMPUTE_D_TERM_FINISH;
                end
                
                COMPUTE_D_TERM_FINISH: begin
                    d_term <= temp_mult >>> FP_SHIFT;
                    state <= FINALIZE;
                end
                
                FINALIZE: begin
                    // Sum all terms to get the final integral result
                    integral_result <= a_term + b_term + c_term + d_term;
                    state <= DONE;
                end
                
                DONE: begin
                    is_computation_complete <= 1;
                    
                    // Return to IDLE if start signal is deasserted
                    if (!start_computation) begin
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
