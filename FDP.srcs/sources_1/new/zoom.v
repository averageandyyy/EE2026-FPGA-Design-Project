`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2025 17:51:42
// Design Name: 
// Module Name: zoom
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


module zoom_button(
    input        basys_clock,
    input        up_btn,      // tap for zoom in
    input        down_btn,    // tap for zoom out
    input        middle_btn,  // must be held to enable up/down actions
    input        graph_mode_check,
    output reg [15:0] LEDS,       // 16-bit LED output (LED15 is MSB)
    output reg [2:0] zoom_state = 3
);

    // Mode register: 0 to 6 (7 discrete zoom levels).
    // Default mode = 3 corresponds to "LEDs 15:8 on".
    reg [2:0] mode;
    initial mode = 3;

    // For edge detection: store previous states of up and down buttons.
    reg up_last, down_last;
    initial begin
        up_last   = 1'b0;
        down_last = 1'b0;
    end

    // We'll map the current mode to a number of LEDs turned on.
    // Mode mapping:
    //   Mode 0: 0 on,
    //   Mode 1: 3 on,
    //   Mode 2: 5 on,
    //   Mode 3: 8 on,  // default
    //   Mode 4: 11 on,
    //   Mode 5: 14 on,
    //   Mode 6: 16 on.
    reg [4:0] num_leds;
    always @(posedge basys_clock) begin
        case (mode)
            3'd0: begin num_leds <= 0; zoom_state <= 3'd0; end
            3'd1: begin num_leds <= 3; zoom_state <= 3'd1; end
            3'd2: begin num_leds <= 5; zoom_state <= 3'd2; end
            3'd3: begin num_leds <= 8; zoom_state <= 3'd3; end
            3'd4: begin num_leds <= 11; zoom_state <= 3'd4; end
            3'd5: begin num_leds <= 14; zoom_state <= 3'd5; end
            3'd6: begin num_leds <= 16; zoom_state <= 3'd6; end
            default: begin num_leds <= 8; zoom_state <= 3'd7; end
        endcase
    end

    // Update mode on a rising edge of up/down buttons (only when middle_btn is held).
    // We use clocked logic for edge detection.
    always @(posedge basys_clock) begin
        if (graph_mode_check) begin
            // Check for rising edge on up_btn:
            if (middle_btn && up_btn && !up_last) begin
                if (mode < 6)
                    mode <= mode + 1;
            end
            // Check for rising edge on down_btn:
            if (middle_btn && down_btn && !down_last) begin
                if (mode > 0)
                    mode <= mode - 1;
            end
        end
        // Update previous states for next clock cycle.
        up_last   <= up_btn;
        down_last <= down_btn;
    end

    // Build the LED pattern (16 bits) from num_leds.
    // We want the highest (MSB) num_leds to be 1.
    // For example, if num_leds is 8, then LEDS[15:8] are 1 and LEDS[7:0] are 0.
    reg [15:0] led_pattern;
    integer i;
    always @(posedge basys_clock) begin
        led_pattern <= 16'b0;
        for (i = 0; i < 16; i = i + 1) begin
            if (i < num_leds)
                led_pattern[15 - i] <= 1'b1;
            else
                led_pattern[15 - i] <= 1'b0;
        end
    end

    // Drive the LEDS output.
    always @(posedge basys_clock) begin
        if (graph_mode_check)
            LEDS <= led_pattern;
    end

endmodule
