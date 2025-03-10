`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2025 17:04:55
// Design Name: 
// Module Name: collision_module
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


module collision_module(
    input basys_clock,
    input btnU,
    input btnD,
    input btnL,
    input btnR,
    input [12:0]pixel_index,
    output reg[15:0]oled_data,
    input hasPassword
    );
    
    // Obtain pixel coordinates
    wire [7:0] x;
    wire [7:0] y;
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
        
    // Top left pixel of green square
    reg [7:0] curr_x;
    reg [7:0] curr_y;
    
    // Colour parameters
    parameter [15:0]RED = 16'b11111_000000_00000;
    parameter [15:0]GREEN = 16'b00000_111111_00000;
    
    //update the btn state every 1ms --> 1000Hz
    wire clk1kHz;
    flexible_clock_divider unit_0 (basys_clock, 49999, clk1kHz);
    
    // Loop to update color based on pixel position
    always @ (posedge basys_clock) begin
    
    if (hasPassword) begin
        if (x <= 95 && x >= 66 && y >= 0 && y <= 29) begin
            oled_data <= RED;
        end
        else if (x >= curr_x && x <= curr_x + 9 && y >= curr_y && y <= curr_y + 9) begin
            oled_data <= GREEN;
        end    
        else begin 
            oled_data <= 16'b0;
        end
        end
    else begin
        oled_data <= 0;
    end
    end
    
    
    reg [1:0] direction;
    reg prevU;
    reg prevD;
    reg prevL;
    reg prevR;
    // Loop to update direction of movement, 00 = left, 01 = right, 10 = up, 11 = down
    always @ (posedge clk1kHz) begin
    if (hasPassword) begin
        if (prevR && !btnR) begin
            direction <= 2'b01;
        end
        else if (prevU && !btnU) begin
            direction <= 2'b10;    
        end
        else if (prevL && !btnL) begin
            direction <= 2'b00;    
        end
        else if (prevD && !btnD) begin
            direction <= 2'b11;    
        end
        
        prevU <= btnU;
        prevD <= btnD;
        prevL <= btnL;
        prevR <= btnR;
    end
    
    else direction <= 2'b11;
    end
    
    // Variables to check for screen collision
    wire left_bound_collision = (curr_x == 0);
    wire right_bound_collision = (curr_x == 86);
    wire top_bound_collision = (curr_y == 0);
    wire bottom_bound_collision = (curr_y == 54);
    
    // Variables for box collision
    wire left_box_bound_collision = (curr_x == 56 && curr_y >= 0 && curr_y <= 29);
    wire bottom_box_bound_collision = (curr_y == 30 && curr_x <= 86 && curr_x >= 56); 
    
    wire can_move_up = ~top_bound_collision & ~bottom_box_bound_collision;
    wire can_move_down = ~bottom_bound_collision;
    wire can_move_left = ~left_bound_collision;
    wire can_move_right = ~right_bound_collision & ~left_box_bound_collision;

    // Animation loop, 00 = left, 01 = right, 10 = up, 11 = down
    wire clk_30Hz;
    flexible_clock_divider unit_1 (basys_clock, 1666666, clk_30Hz);
    always @ (posedge clk_30Hz) begin
    if (hasPassword) begin
        if (direction == 2'b00 && can_move_left) begin
            curr_x <= curr_x - 1;
        end
        else if (direction == 2'b01 && can_move_right) begin
            curr_x <= curr_x + 1;
        end
        else if (direction == 2'b10 && can_move_up) begin
            curr_y <= curr_y - 1;
        end
        else if (direction == 2'b11 && can_move_down) begin
            curr_y <= curr_y + 1;
        end
        
//        if (direction == 2'b01 && (curr_x < 86)) begin
//            if (curr_y >= 30) curr_x <= curr_x + 1; //able to move right
//            else if (curr_x < 55) curr_x <= curr_x + 1;
//        end
//        else if (direction == 2'b00 && (curr_x > 0)) 
//            curr_x <= curr_x - 1; //able to move left
//        else if (direction == 2'b10 && curr_y > 0) begin
//            if (curr_x <= 55) curr_y <= curr_y - 1; 
//            else if ((curr_y) > 31) //check top left edge for collision
//                curr_y <= curr_y - 1; //able to move up
//        end
//            //else if (curr_y <= 31) curr_y <= curr_y - 1;
//        //end
//        else if (direction == 2'b11 && (curr_y < 53))
//            curr_y <= curr_y + 1; //able to move down
    end     
    else begin  
        curr_x = 0;
        curr_y = 54;
    end   
    end
   
    
    initial begin
        oled_data = 16'b0;
        direction = 2'b11;
        curr_x = 0;
        curr_y = 54;
        prevU = 0;
        prevD = 0;
        prevL = 0;
        prevR = 0;
    end
endmodule
