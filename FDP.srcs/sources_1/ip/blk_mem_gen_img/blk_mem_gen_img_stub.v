// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Sat Mar 29 17:07:55 2025
// Host        : DESKTOP-4JEN3JE running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top blk_mem_gen_img -prefix
//               blk_mem_gen_img_ blk_mem_gen_img_stub.v
// Design      : blk_mem_gen_img
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2018.2" *)
module blk_mem_gen_img(clka, wea, addra, dina, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[9:0],dina[0:0],clkb,addrb[9:0],doutb[0:0]" */;
  input clka;
  input [0:0]wea;
  input [9:0]addra;
  input [0:0]dina;
  input clkb;
  input [9:0]addrb;
  output [0:0]doutb;
endmodule
