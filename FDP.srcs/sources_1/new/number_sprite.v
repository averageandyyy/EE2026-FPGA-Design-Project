`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2025 14:50:56
// Design Name: 
// Module Name: number_sprites
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


module number_sprites(
    input [5:0] character,
    input [3:0] row,        
    output reg [7:0] pixels  
    );
    
    always @(*) begin
        case ({character, row})
            // Number '0'
                                                    10'bq               1_1011: pixels = 8'b00000000;

                    
            default: pixels = 8'b00000000; // Blank row for undefined cases // Blank row for undefined cases
        endcase
    end
    
endmodule
