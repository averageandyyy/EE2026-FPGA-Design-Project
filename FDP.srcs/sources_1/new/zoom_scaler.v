`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.03.2025 23:25:10
// Design Name: 
// Module Name: zoom_scaler
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


module zoom_scaler(
    input         basys_clock,
    input  [12:0] pixel_index,         // Current display pixel index (0 to 6143 for 96x64)
    input  [2:0]  zoom_mode,           // 3-bit zoom mode: 0 to 6 (default 3 is 1:1 scale)
    output reg [12:0] scaled_pixel_index, // New pixel index to address the original image
    input graph_mode_check
);

    // --- Step 1: Determine the scale factor (fixed-point, scale*100) based on zoom_mode.
    // For example:
    //   Mode 0: 0.40x -> 40
    //   Mode 1: 0.60x -> 60
    //   Mode 2: 0.80x -> 80
    //   Mode 3: 1.00x -> 100
    //   Mode 4: 1.25x -> 125
    //   Mode 5: 1.50x -> 150
    //   Mode 6: 2.00x -> 200
    reg [7:0] scale;  // Scale factor times 100
    always @(posedge basys_clock) begin
        if (graph_mode_check) begin
        case (zoom_mode)
            3'd0: scale <= 8'd40;
            3'd1: scale <= 8'd60;
            3'd2: scale <= 8'd80;
            3'd3: scale <= 8'd100;
            3'd4: scale <= 8'd125;
            3'd5: scale <= 8'd150;
            3'd6: scale <= 8'd200;
            default: scale <= 8'd100;
        endcase
        end
    end

    // --- Step 2: Convert pixel_index into display coordinates (x_disp, y_disp)
    reg [7:0] X_disp, Y_disp;
    always @(posedge basys_clock) begin
        // Since the display is 96x64, we compute:
       if (graph_mode_check) begin
        X_disp <= pixel_index % 96;
        Y_disp <= pixel_index / 96;
        end
    end

    // --- Step 3: Compute the corresponding coordinates (X_img, Y_img) in the original image.
    // We assume the center of the display (48,32) is the pivot.
    // Use signed arithmetic to allow negative differences.
    reg signed [15:0] X_img, Y_img;
    always @(posedge basys_clock) begin
        // Multiply the difference by 100 and then divide by scale.
        // When zoom_mode = 3 (scale=100), the mapping is identity.
        X_img <= 48 + ((( $signed({1'b0, X_disp}) - 48) * 100) / scale);
        Y_img <= 32 + ((( $signed({1'b0, Y_disp}) - 32) * 100) / scale);
    end

    // --- Step 4: Clamp the computed coordinates to the valid ranges: [0,95] for x, [0,63] for y.
    reg [7:0] X_clamped, Y_clamped;
    always @(posedge basys_clock) begin
        if (graph_mode_check) begin
        if (X_img < 0)
            X_clamped <= 0;
        else if (X_img > 95)
            X_clamped <= 95;
        else
            X_clamped <= X_img[7:0];
            
        if (Y_img < 0)
            Y_clamped <= 0;
        else if (Y_img > 63)
            Y_clamped <= 63;
        else
            Y_clamped <= Y_img[7:0];
            end
    end

    // --- Step 5: Compute the scaled pixel index.
    // The pixel index = Y_clamped * 96 + X_clamped.
    always @(posedge basys_clock) begin
    if (graph_mode_check) begin
        scaled_pixel_index <= Y_clamped * 96 + X_clamped;
    end
    end
endmodule
