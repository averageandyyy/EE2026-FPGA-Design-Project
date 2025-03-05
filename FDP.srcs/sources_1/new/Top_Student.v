`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (input basys_clock, btnU, btnC, btnD, input [7:0] sw, output [7:0]JB);

    basic_task_b unitb(basys_clock, btnU, btnC, btnD, JB);

endmodule