`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2025 20:50:03
// Design Name: 
// Module Name: render_segments
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


module render_segments(
    input input_clock,
    output reg [3:0]an,
    output reg [7:0]seg
    );
    
    parameter [7:0]S = 8'b1_0010010;
    parameter [7:0]TWO = 8'b0_0100100;
    parameter [7:0]ZERO = 8'b1_1000000;
    parameter [7:0]SEVEN = 8'b1_1111000;
    
    reg [1:0] state;
    
    initial begin
        state = 2'b0;
        an = 4'b1111;
        seg = 8'b1_1111111;
    end
    
    always @ (posedge input_clock)
    begin
        if (state == 2'b00) begin
            an <= 4'b0111;
            seg <= S;
        end
        else if (state == 2'b01) begin
            an <= 4'b1011;
            seg <= TWO;
        end
        else if (state == 2'b10) begin
            an <= 4'b1101;
            seg <= ZERO;
        end
        else if (state == 2'b11) begin
            an <= 4'b1110;
            seg <= SEVEN;
        end
        
        state <= state + 1;
    end
endmodule
