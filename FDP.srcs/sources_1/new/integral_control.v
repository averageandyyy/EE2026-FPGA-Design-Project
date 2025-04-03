`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2025 13:36:29
// Design Name: 
// Module Name: integral_control
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


module integral_control(
    input clk,
    input reset,
    input btnC,
    input is_integral_mode,

    // From input_builder
    input input_complete,
    input signed [31:0] fp_value,

    // From computation module
    input is_computation_complete,
    input signed [31:0] computation_result,
    
    // Control outputs for other modules
    output reg is_integral_input_mode,
    output reg is_input_a,              
    output reg is_input_b,              
    output reg signed [31:0] a_lower,
    output reg signed [31:0] b_upper,

    // Signal for computation module
    output reg start_computation,
    output reg is_complete,
    output reg signed [31:0] integral_result, 
    
    // Controls for unified_input_bcd_to_fp_builder
    output reg is_active_mode       
    );

    // State definitions
    localparam IDLE = 2'd0;
    localparam OBTAIN_A = 2'd1;
    localparam OBTAIN_B = 2'd2;
    localparam COMPUTE = 2'd3;
    
    // Current state register
    reg [1:0] state = IDLE;
    
    // Button debounce
    reg prev_btnC = 0;
    reg [7:0] debounce_C = 0;
    
    // State machine
    always @(posedge clk) begin
        if (reset || !is_integral_mode) begin
            // Reset all control signals and state
            state <= IDLE;
            is_integral_input_mode <= 0;
            is_input_a <= 0;
            is_input_b <= 0;
            a_lower <= 0;
            b_upper <= 0;
            start_computation <= 0;
            is_complete <= 0;
            integral_result <= 0;
            is_active_mode <= 0;
            prev_btnC <= 0;
            debounce_C <= 0;
        end
        else begin
            // Handle button debounce
            if (debounce_C > 0) debounce_C <= debounce_C - 1;
            
            // Button handling for restarting loop
            if (btnC && !prev_btnC && debounce_C == 0) begin
                if (is_complete) begin
                    // Reset completion flag to restart loop
                    is_complete <= 0;  
                    debounce_C <= 100;
                end
            end
            prev_btnC <= btnC;
            
            // Main state machine
            case (state)
                IDLE: begin
                    // Ensure computation is not running
                    start_computation <= 0;
                    
                    // Check if we need to start a new computation cycle
                    if (!is_complete) begin
                        state <= OBTAIN_A;
                        is_integral_input_mode <= 1;
                        is_input_a <= 1;
                        is_input_b <= 0;
                        // Activate input builder
                        is_active_mode <= 1;   
                    end
                end
                
                OBTAIN_A: begin
                    // Wait for user to complete input A
                    if (input_complete) begin
                        // Store the lower bound
                        a_lower <= fp_value;
                        
                        // Reset the input builder and cursor controller
                        is_active_mode <= 0;   
                        is_integral_input_mode <= 0;
                        
                        // Move to next state
                        state <= OBTAIN_B;
                        is_input_a <= 0;
                        is_input_b <= 1;
                    end
                end
                
                OBTAIN_B: begin
                    // Make sure the input builder is active
                    if (!is_active_mode && !is_integral_input_mode) begin
                        is_active_mode <= 1;
                        is_integral_input_mode <= 1;
                    end
                    
                    // Wait for user to complete input B
                    if (input_complete) begin
                        // Store the upper bound
                        b_upper <= fp_value;
                        
                        // Deactivate input mode
                        is_integral_input_mode <= 0;
                        is_active_mode <= 0;
                        is_input_b <= 0;
                        
                        // Start computation
                        start_computation <= 1;
                        state <= COMPUTE;
                    end
                end
                
                COMPUTE: begin
                    // Wait for computation to complete
                    if (is_computation_complete) begin
                        // Store the result
                        integral_result <= computation_result;
                        is_complete <= 1;
                        start_computation <= 0;
                        
                        // Return to IDLE
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
