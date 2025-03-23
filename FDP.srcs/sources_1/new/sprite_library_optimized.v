`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2025 11:42:28
// Design Name: 
// Module Name: sprite_library_optimized
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


module sprite_library_optimized(
    input [5:0] character,
    input [3:0] row,
    output reg [7:0] pixels
    );
    // Character data ROM - this structure synthesizes much more efficiently to BRAM
    // BRAM or Block RAM is a dedicated memory resource on the FPGA that is optimized for storing large amounts of data
    // Use BRAM instead of logic elements aka LUTs/FFs
    (* ram_style = "block" *) reg [7:0] char_rom[0:63][0:11];

    // Initialize ROM with character patterns
    initial begin
        // Digit 0
        char_rom[0][0] = 8'b00011000; char_rom[0][1] = 8'b00111100;
        char_rom[0][2] = 8'b01101110; char_rom[0][3] = 8'b01100110;
        char_rom[0][4] = 8'b01101110; char_rom[0][5] = 8'b01101110;
        char_rom[0][6] = 8'b01110110; char_rom[0][7] = 8'b01110110;
        char_rom[0][8] = 8'b01100110; char_rom[0][9] = 8'b01100110;
        char_rom[0][10] = 8'b00111100; char_rom[0][11] = 8'b00011000;
        
        // Digit 1-9 (adding all digits 1-9 here from your original file)
        // Digit 1
        char_rom[1][0] = 8'b00011000; char_rom[1][1] = 8'b00111000;
        char_rom[1][2] = 8'b01111000; char_rom[1][3] = 8'b00011000;
        char_rom[1][4] = 8'b00011000; char_rom[1][5] = 8'b00011000;
        char_rom[1][6] = 8'b00011000; char_rom[1][7] = 8'b00011000;
        char_rom[1][8] = 8'b00011000; char_rom[1][9] = 8'b00011000;
        char_rom[1][10] = 8'b01111110; char_rom[1][11] = 8'b01111110;
        
        // Digit 2
        char_rom[2][0] = 8'b00011000; char_rom[2][1] = 8'b00111100;
        char_rom[2][2] = 8'b01100110; char_rom[2][3] = 8'b01100110;
        char_rom[2][4] = 8'b00000110; char_rom[2][5] = 8'b00000110;
        char_rom[2][6] = 8'b00001100; char_rom[2][7] = 8'b00011000;
        char_rom[2][8] = 8'b00110000; char_rom[2][9] = 8'b00110000;
        char_rom[2][10] = 8'b01111110; char_rom[2][11] = 8'b01111110;
        
        // Digit 3
        char_rom[3][0] = 8'b00011000; char_rom[3][1] = 8'b00111100;
        char_rom[3][2] = 8'b01100110; char_rom[3][3] = 8'b01100110;
        char_rom[3][4] = 8'b00001100; char_rom[3][5] = 8'b00111000;
        char_rom[3][6] = 8'b00111000; char_rom[3][7] = 8'b00001100;
        char_rom[3][8] = 8'b01100110; char_rom[3][9] = 8'b01100110;
        char_rom[3][10] = 8'b00111100; char_rom[3][11] = 8'b00011000;
        
        // Digit 4
        char_rom[4][0] = 8'b00000110; char_rom[4][1] = 8'b00001110;
        char_rom[4][2] = 8'b00011110; char_rom[4][3] = 8'b00110110;
        char_rom[4][4] = 8'b01100110; char_rom[4][5] = 8'b01111110;
        char_rom[4][6] = 8'b01111110; char_rom[4][7] = 8'b00000110;
        char_rom[4][8] = 8'b00000110; char_rom[4][9] = 8'b00000110;
        char_rom[4][10] = 8'b00000110; char_rom[4][11] = 8'b00000110;
        
        // Digit 5
        char_rom[5][0] = 8'b01111110; char_rom[5][1] = 8'b01111110;
        char_rom[5][2] = 8'b01100000; char_rom[5][3] = 8'b01100000;
        char_rom[5][4] = 8'b01100000; char_rom[5][5] = 8'b01111100;
        char_rom[5][6] = 8'b01111110; char_rom[5][7] = 8'b00000110;
        char_rom[5][8] = 8'b00000110; char_rom[5][9] = 8'b01100110;
        char_rom[5][10] = 8'b00111100; char_rom[5][11] = 8'b00011000;
        
        // Digit 6
        char_rom[6][0] = 8'b00011000; char_rom[6][1] = 8'b00111100;
        char_rom[6][2] = 8'b01100110; char_rom[6][3] = 8'b01100110;
        char_rom[6][4] = 8'b01100000; char_rom[6][5] = 8'b01111100;
        char_rom[6][6] = 8'b01100110; char_rom[6][7] = 8'b01100110;
        char_rom[6][8] = 8'b01100110; char_rom[6][9] = 8'b01111110;
        char_rom[6][10] = 8'b00111100; char_rom[6][11] = 8'b00011000;
        
        // Digit 7
        char_rom[7][0] = 8'b01111110; char_rom[7][1] = 8'b01111110;
        char_rom[7][2] = 8'b00001100; char_rom[7][3] = 8'b00001100;
        char_rom[7][4] = 8'b00001100; char_rom[7][5] = 8'b00011000;
        char_rom[7][6] = 8'b00011000; char_rom[7][7] = 8'b00011000;
        char_rom[7][8] = 8'b00110000; char_rom[7][9] = 8'b00110000;
        char_rom[7][10] = 8'b00110000; char_rom[7][11] = 8'b00110000;
        
        // Digit 8
        char_rom[8][0] = 8'b00011000; char_rom[8][1] = 8'b00111100;
        char_rom[8][2] = 8'b01100110; char_rom[8][3] = 8'b01100110;
        char_rom[8][4] = 8'b01100110; char_rom[8][5] = 8'b00111100;
        char_rom[8][6] = 8'b00111100; char_rom[8][7] = 8'b01100110;
        char_rom[8][8] = 8'b01100110; char_rom[8][9] = 8'b01100110;
        char_rom[8][10] = 8'b01111110; char_rom[8][11] = 8'b00011000;
        
        // Digit 9
        char_rom[9][0] = 8'b00111110; char_rom[9][1] = 8'b00110110;
        char_rom[9][2] = 8'b01100110; char_rom[9][3] = 8'b01100110;
        char_rom[9][4] = 8'b01100110; char_rom[9][5] = 8'b00111110;
        char_rom[9][6] = 8'b00000110; char_rom[9][7] = 8'b00000110;
        char_rom[9][8] = 8'b00000110; char_rom[9][9] = 8'b00000110;
        char_rom[9][10] = 8'b00000110; char_rom[9][11] = 8'b00000110;
        
        // Plus Sign '+'
        char_rom[10][0] = 8'b00000000; char_rom[10][1] = 8'b00000000;
        char_rom[10][2] = 8'b00000000; char_rom[10][3] = 8'b00011000;
        char_rom[10][4] = 8'b00011000; char_rom[10][5] = 8'b01111110;
        char_rom[10][6] = 8'b01111110; char_rom[10][7] = 8'b00011000;
        char_rom[10][8] = 8'b00011000; char_rom[10][9] = 8'b00000000;
        char_rom[10][10] = 8'b00000000; char_rom[10][11] = 8'b00000000;
        
        // Minus Sign '-'
        char_rom[11][0] = 8'b00000000; char_rom[11][1] = 8'b00000000;
        char_rom[11][2] = 8'b00000000; char_rom[11][3] = 8'b00000000;
        char_rom[11][4] = 8'b00000000; char_rom[11][5] = 8'b01111110;
        char_rom[11][6] = 8'b01111110; char_rom[11][7] = 8'b00000000;
        char_rom[11][8] = 8'b00000000; char_rom[11][9] = 8'b00000000;
        char_rom[11][10] = 8'b00000000; char_rom[11][11] = 8'b00000000;
        
        // Multiply Sign 'x'
        char_rom[12][0] = 8'b00000000; char_rom[12][1] = 8'b00000000;
        char_rom[12][2] = 8'b01100110; char_rom[12][3] = 8'b01100110;
        char_rom[12][4] = 8'b00111100; char_rom[12][5] = 8'b00011000;
        char_rom[12][6] = 8'b00011000; char_rom[12][7] = 8'b00111100;
        char_rom[12][8] = 8'b01100110; char_rom[12][9] = 8'b01100110;
        char_rom[12][10] = 8'b00000000; char_rom[12][11] = 8'b00000000;
        
        // Division '/'
        char_rom[13][0] = 8'b00000000; char_rom[13][1] = 8'b00011000;
        char_rom[13][2] = 8'b00011000; char_rom[13][3] = 8'b00000000;
        char_rom[13][4] = 8'b00000000; char_rom[13][5] = 8'b01111110;
        char_rom[13][6] = 8'b01111110; char_rom[13][7] = 8'b00000000;
        char_rom[13][8] = 8'b00000000; char_rom[13][9] = 8'b00011000;
        char_rom[13][10] = 8'b00011000; char_rom[13][11] = 8'b00000000;
        
        // Decimal point
        char_rom[14][0] = 8'b00000000; char_rom[14][1] = 8'b00000000;
        char_rom[14][2] = 8'b00000000; char_rom[14][3] = 8'b00000000;
        char_rom[14][4] = 8'b00000000; char_rom[14][5] = 8'b00000000;
        char_rom[14][6] = 8'b00000000; char_rom[14][7] = 8'b00000000;
        char_rom[14][8] = 8'b00000000; char_rom[14][9] = 8'b00000000;
        char_rom[14][10] = 8'b00110000; char_rom[14][11] = 8'b00110000;
        
        // Continue for all remaining characters (A-Z)...
        // Capital 'A'
        char_rom[15][0] = 8'b00011000; char_rom[15][1] = 8'b00011000;
        char_rom[15][2] = 8'b00111100; char_rom[15][3] = 8'b00111100;
        char_rom[15][4] = 8'b01100110; char_rom[15][5] = 8'b01100110;
        char_rom[15][6] = 8'b01111110; char_rom[15][7] = 8'b01111110;
        char_rom[15][8] = 8'b01100110; char_rom[15][9] = 8'b01100110;
        char_rom[15][10] = 8'b01100110; char_rom[15][11] = 8'b01100110;

        // Capital 'B' - fixed index
        char_rom[16][0] = 8'b01111100; char_rom[16][1] = 8'b01111110;
        char_rom[16][2] = 8'b01100110; char_rom[16][3] = 8'b01100110;
        char_rom[16][4] = 8'b01111100; char_rom[16][5] = 8'b01111100;
        char_rom[16][6] = 8'b01111110; char_rom[16][7] = 8'b01100110;
        char_rom[16][8] = 8'b01100110; char_rom[16][9] = 8'b01100110;
        char_rom[16][10] = 8'b01111110; char_rom[16][11] = 8'b01111100;
        
        // Capital 'C'
        char_rom[17][0] = 8'b00011000; char_rom[17][1] = 8'b00111100;
        char_rom[17][2] = 8'b01100110; char_rom[17][3] = 8'b01100110;
        char_rom[17][4] = 8'b01100000; char_rom[17][5] = 8'b01100000;
        char_rom[17][6] = 8'b01100000; char_rom[17][7] = 8'b01100000;
        char_rom[17][8] = 8'b01100110; char_rom[17][9] = 8'b01100110;
        char_rom[17][10] = 8'b00111100; char_rom[17][11] = 8'b00011000;
        
        // Capital 'D'
        char_rom[18][0] = 8'b01111000; char_rom[18][1] = 8'b01111110;
        char_rom[18][2] = 8'b01100110; char_rom[18][3] = 8'b01100110;
        char_rom[18][4] = 8'b01100110; char_rom[18][5] = 8'b01100110;
        char_rom[18][6] = 8'b01100110; char_rom[18][7] = 8'b01100110;
        char_rom[18][8] = 8'b01101100; char_rom[18][9] = 8'b01101100;
        char_rom[18][10] = 8'b01111000; char_rom[18][11] = 8'b01110000;
        
        // Capital 'E'
        char_rom[19][0] = 8'b01111110; char_rom[19][1] = 8'b01111110;
        char_rom[19][2] = 8'b01100000; char_rom[19][3] = 8'b01100000;
        char_rom[19][4] = 8'b01100000; char_rom[19][5] = 8'b01111110;
        char_rom[19][6] = 8'b01111110; char_rom[19][7] = 8'b01100000;
        char_rom[19][8] = 8'b01100000; char_rom[19][9] = 8'b01100000;
        char_rom[19][10] = 8'b01111110; char_rom[19][11] = 8'b01111110;
        
        // Capital 'F'
        char_rom[20][0] = 8'b01111110; char_rom[20][1] = 8'b01111110;
        char_rom[20][2] = 8'b01100000; char_rom[20][3] = 8'b01100000;
        char_rom[20][4] = 8'b01100000; char_rom[20][5] = 8'b01100000;
        char_rom[20][6] = 8'b01111100; char_rom[20][7] = 8'b01111100;
        char_rom[20][8] = 8'b01100000; char_rom[20][9] = 8'b01100000;
        char_rom[20][10] = 8'b01100000; char_rom[20][11] = 8'b01100000;
        
        // Capital 'G'
        char_rom[21][0] = 8'b00011000; char_rom[21][1] = 8'b00111100;
        char_rom[21][2] = 8'b01100110; char_rom[21][3] = 8'b01100110;
        char_rom[21][4] = 8'b01100110; char_rom[21][5] = 8'b01100000;
        char_rom[21][6] = 8'b01101110; char_rom[21][7] = 8'b01101110;
        char_rom[21][8] = 8'b01100110; char_rom[21][9] = 8'b01100110;
        char_rom[21][10] = 8'b00111110; char_rom[21][11] = 8'b00011000;
        
        // Capital 'H'
        char_rom[22][0] = 8'b01100110; char_rom[22][1] = 8'b01100110;
        char_rom[22][2] = 8'b01100110; char_rom[22][3] = 8'b01100110;
        char_rom[22][4] = 8'b01100110; char_rom[22][5] = 8'b01111110;
        char_rom[22][6] = 8'b01111110; char_rom[22][7] = 8'b01100110;
        char_rom[22][8] = 8'b01100110; char_rom[22][9] = 8'b01100110;
        char_rom[22][10] = 8'b01100110; char_rom[22][11] = 8'b01100110;
        
        // Capital 'I'
        char_rom[23][0] = 8'b01111110; char_rom[23][1] = 8'b01111110;
        char_rom[23][2] = 8'b00011000; char_rom[23][3] = 8'b00011000;
        char_rom[23][4] = 8'b00011000; char_rom[23][5] = 8'b00011000;
        char_rom[23][6] = 8'b00011000; char_rom[23][7] = 8'b00011000;
        char_rom[23][8] = 8'b00011000; char_rom[23][9] = 8'b00011000;
        char_rom[23][10] = 8'b01111110; char_rom[23][11] = 8'b01111110;
        
        // Capital 'J'
        char_rom[24][0] = 8'b00111110; char_rom[24][1] = 8'b00111110;
        char_rom[24][2] = 8'b00001100; char_rom[24][3] = 8'b00001100;
        char_rom[24][4] = 8'b00001100; char_rom[24][5] = 8'b00001100;
        char_rom[24][6] = 8'b00001100; char_rom[24][7] = 8'b00001100;
        char_rom[24][8] = 8'b01101100; char_rom[24][9] = 8'b01101100;
        char_rom[24][10] = 8'b00111100; char_rom[24][11] = 8'b00011000;
        
        // Capital 'K'
        char_rom[25][0] = 8'b01100110; char_rom[25][1] = 8'b01100110;
        char_rom[25][2] = 8'b01101100; char_rom[25][3] = 8'b01101100;
        char_rom[25][4] = 8'b01111000; char_rom[25][5] = 8'b01110000;
        char_rom[25][6] = 8'b01100000; char_rom[25][7] = 8'b01111000;
        char_rom[25][8] = 8'b01101100; char_rom[25][9] = 8'b01101100;
        char_rom[25][10] = 8'b01100110; char_rom[25][11] = 8'b01100110;
        
        // Capital 'L'
        char_rom[26][0] = 8'b01100000; char_rom[26][1] = 8'b01100000;
        char_rom[26][2] = 8'b01100000; char_rom[26][3] = 8'b01100000;
        char_rom[26][4] = 8'b01100000; char_rom[26][5] = 8'b01100000;
        char_rom[26][6] = 8'b01100000; char_rom[26][7] = 8'b01100000;
        char_rom[26][8] = 8'b01100000; char_rom[26][9] = 8'b01100000;
        char_rom[26][10] = 8'b01111110; char_rom[26][11] = 8'b01111110;
        
        // Capital 'M'
        char_rom[27][0] = 8'b01000010; char_rom[27][1] = 8'b01100110;
        char_rom[27][2] = 8'b01100110; char_rom[27][3] = 8'b01111110;
        char_rom[27][4] = 8'b01111110; char_rom[27][5] = 8'b01011010;
        char_rom[27][6] = 8'b01011010; char_rom[27][7] = 8'b01000010;
        char_rom[27][8] = 8'b01000010; char_rom[27][9] = 8'b01000010;
        char_rom[27][10] = 8'b01000010; char_rom[27][11] = 8'b01000010;
        
        // Capital 'N'
        char_rom[28][0] = 8'b01100110; char_rom[28][1] = 8'b01100110;
        char_rom[28][2] = 8'b01100110; char_rom[28][3] = 8'b01110110;
        char_rom[28][4] = 8'b01110110; char_rom[28][5] = 8'b01111110;
        char_rom[28][6] = 8'b01111110; char_rom[28][7] = 8'b01101110;
        char_rom[28][8] = 8'b01101110; char_rom[28][9] = 8'b01101110;
        char_rom[28][10] = 8'b01100110; char_rom[28][11] = 8'b01100110;
        
        // Capital 'O'
        char_rom[29][0] = 8'b00111100; char_rom[29][1] = 8'b01111110;
        char_rom[29][2] = 8'b01100110; char_rom[29][3] = 8'b01100110;
        char_rom[29][4] = 8'b01100110; char_rom[29][5] = 8'b01100110;
        char_rom[29][6] = 8'b01100110; char_rom[29][7] = 8'b01100110;
        char_rom[29][8] = 8'b01100110; char_rom[29][9] = 8'b01100110;
        char_rom[29][10] = 8'b01111110; char_rom[29][11] = 8'b00111100;
        
        // Capital 'P'
        char_rom[30][0] = 8'b01111100; char_rom[30][1] = 8'b01111110;
        char_rom[30][2] = 8'b01100110; char_rom[30][3] = 8'b01100110;
        char_rom[30][4] = 8'b01100110; char_rom[30][5] = 8'b01111100;
        char_rom[30][6] = 8'b01111000; char_rom[30][7] = 8'b01100000;
        char_rom[30][8] = 8'b01100000; char_rom[30][9] = 8'b01100000;
        char_rom[30][10] = 8'b01100000; char_rom[30][11] = 8'b01100000;
        
        // Capital 'Q'
        char_rom[31][0] = 8'b00111100; char_rom[31][1] = 8'b01100110;
        char_rom[31][2] = 8'b01100110; char_rom[31][3] = 8'b01100110;
        char_rom[31][4] = 8'b01100110; char_rom[31][5] = 8'b01100110;
        char_rom[31][6] = 8'b01100110; char_rom[31][7] = 8'b01110110;
        char_rom[31][8] = 8'b01101110; char_rom[31][9] = 8'b01111110;
        char_rom[31][10] = 8'b00011100; char_rom[31][11] = 8'b00000110;
        
        // Space character (blank) - already at index 32

        // Capital 'R'
        char_rom[33][0] = 8'b01111100; char_rom[33][1] = 8'b01111110;
        char_rom[33][2] = 8'b01100110; char_rom[33][3] = 8'b01100110;
        char_rom[33][4] = 8'b01111100; char_rom[33][5] = 8'b01111000;
        char_rom[33][6] = 8'b01111000; char_rom[33][7] = 8'b01101100;
        char_rom[33][8] = 8'b01101100; char_rom[33][9] = 8'b01100110;
        char_rom[33][10] = 8'b01100110; char_rom[33][11] = 8'b01100110;
        
        // Capital 'S'
        char_rom[34][0] = 8'b00011000; char_rom[34][1] = 8'b00111100;
        char_rom[34][2] = 8'b01100110; char_rom[34][3] = 8'b01100000;
        char_rom[34][4] = 8'b00110000; char_rom[34][5] = 8'b00011000;
        char_rom[34][6] = 8'b00001100; char_rom[34][7] = 8'b00001100;
        char_rom[34][8] = 8'b01100110; char_rom[34][9] = 8'b01100110;
        char_rom[34][10] = 8'b00111100; char_rom[34][11] = 8'b00011000;
        
        // Capital 'T'
        char_rom[35][0] = 8'b01111110; char_rom[35][1] = 8'b01111110;
        char_rom[35][2] = 8'b00011000; char_rom[35][3] = 8'b00011000;
        char_rom[35][4] = 8'b00011000; char_rom[35][5] = 8'b00011000;
        char_rom[35][6] = 8'b00011000; char_rom[35][7] = 8'b00011000;
        char_rom[35][8] = 8'b00011000; char_rom[35][9] = 8'b00011000;
        char_rom[35][10] = 8'b00011000; char_rom[35][11] = 8'b00011000;
        
        // Capital 'U'
        char_rom[36][0] = 8'b01100110; char_rom[36][1] = 8'b01100110;
        char_rom[36][2] = 8'b01100110; char_rom[36][3] = 8'b01100110;
        char_rom[36][4] = 8'b01100110; char_rom[36][5] = 8'b01100110;
        char_rom[36][6] = 8'b01100110; char_rom[36][7] = 8'b01100110;
        char_rom[36][8] = 8'b01100110; char_rom[36][9] = 8'b00111100;
        char_rom[36][10] = 8'b00111100; char_rom[36][11] = 8'b00111100;
        
        // Capital 'V'
        char_rom[37][0] = 8'b01100110; char_rom[37][1] = 8'b01100110;
        char_rom[37][2] = 8'b01100110; char_rom[37][3] = 8'b01100110;
        char_rom[37][4] = 8'b01100110; char_rom[37][5] = 8'b00100100;
        char_rom[37][6] = 8'b00111100; char_rom[37][7] = 8'b00111100;
        char_rom[37][8] = 8'b00011000; char_rom[37][9] = 8'b00011000;
        char_rom[37][10] = 8'b00011000; char_rom[37][11] = 8'b00011000;
        
        // Capital 'X' (already at index 38)
        // Capital 'Y' (already at index 39)
        
        // Capital 'W'
        char_rom[40][0] = 8'b01000010; char_rom[40][1] = 8'b01000010;
        char_rom[40][2] = 8'b01000010; char_rom[40][3] = 8'b01000010;
        char_rom[40][4] = 8'b01000010; char_rom[40][5] = 8'b01000010;
        char_rom[40][6] = 8'b01011010; char_rom[40][7] = 8'b01011010;
        char_rom[40][8] = 8'b01011010; char_rom[40][9] = 8'b01111110;
        char_rom[40][10] = 8'b01100110; char_rom[40][11] = 8'b01000010;
        
        // Capital 'Z'
        char_rom[41][0] = 8'b01111110; char_rom[41][1] = 8'b01111110;
        char_rom[41][2] = 8'b00001100; char_rom[41][3] = 8'b00001100;
        char_rom[41][4] = 8'b00011000; char_rom[41][5] = 8'b00011000;
        char_rom[41][6] = 8'b00110000; char_rom[41][7] = 8'b00110000;
        char_rom[41][8] = 8'b01100000; char_rom[41][9] = 8'b01100000;
        char_rom[41][10] = 8'b01111110; char_rom[41][11] = 8'b01111110;
        
        // Equals Sign '='
        char_rom[42][0] = 8'b00000000; char_rom[42][1] = 8'b00000000;
        char_rom[42][2] = 8'b00000000; char_rom[42][3] = 8'b00000000;
        char_rom[42][4] = 8'b00000000; char_rom[42][5] = 8'b11111111;
        char_rom[42][6] = 8'b00000000; char_rom[42][7] = 8'b11111111;
        char_rom[42][8] = 8'b00000000; char_rom[42][9] = 8'b00000000;
        char_rom[42][10] = 8'b00000000; char_rom[42][11] = 8'b00000000;

        // Space character (blank)
        char_rom[32][0] = 8'b00000000; char_rom[32][1] = 8'b00000000;
        char_rom[32][2] = 8'b00000000; char_rom[32][3] = 8'b00000000;
        char_rom[32][4] = 8'b00000000; char_rom[32][5] = 8'b00000000;
        char_rom[32][6] = 8'b00000000; char_rom[32][7] = 8'b00000000;
        char_rom[32][8] = 8'b00000000; char_rom[32][9] = 8'b00000000;
        char_rom[32][10] = 8'b00000000; char_rom[32][11] = 8'b00000000;
        
        // X character
        char_rom[38][0] = 8'b01100110; char_rom[38][1] = 8'b01100110;
        char_rom[38][2] = 8'b00111100; char_rom[38][3] = 8'b00111100;
        char_rom[38][4] = 8'b00111100; char_rom[38][5] = 8'b00011000;
        char_rom[38][6] = 8'b00011000; char_rom[38][7] = 8'b00111100;
        char_rom[38][8] = 8'b00111100; char_rom[38][9] = 8'b00111100;
        char_rom[38][10] = 8'b01100110; char_rom[38][11] = 8'b01100110;
        
        // Y character
        char_rom[39][0] = 8'b01100110; char_rom[39][1] = 8'b01100110;
        char_rom[39][2] = 8'b01100110; char_rom[39][3] = 8'b00111100;
        char_rom[39][4] = 8'b00011000; char_rom[39][5] = 8'b00011000;
        char_rom[39][6] = 8'b00011000; char_rom[39][7] = 8'b00011000;
        char_rom[39][8] = 8'b00011000; char_rom[39][9] = 8'b00011000;
        char_rom[39][10] = 8'b00011000; char_rom[39][11] = 8'b00011000;
    end

    always @ (*) begin
        if (row < 12 && character < 64) begin
            pixels = char_rom[character][row];
        end
        else begin
            // Out of bounds default to blank
            pixels = 8'b0;
        end
    end

endmodule
