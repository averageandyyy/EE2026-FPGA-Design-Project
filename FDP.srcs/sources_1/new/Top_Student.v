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


module Top_Student (
    input basys_clock, 
    input [15:0] sw, 
    output [15:0] led,
    input btnC, btnU, btnD, btnL, btnR,
    output [7:0]JB, // First OLED
    output [7:0]JA,  // Second OLED
    output [6:0]seg, // 7-segment display
    output [3:0]an
    );

    // 6.25MHz clock for OLED displays
    wire clk_6p25MHz;
    flexible_clock_divider clk_6p25MHz_gen(
        .main_clock(basys_clock),
        .ticks(7),
        .output_clock(clk_6p25MHz)
    );

    // 1kHz clock for cursor_controller
    wire clk_1kHz;
    flexible_clock_divider clk_1kHz_gen(
        .main_clock(basys_clock),
        .ticks(49999),
        .output_clock(clk_1kHz)
    );


    // First OLED display unit (for user input)
    wire one_frame_begin;
    wire one_sample_pixel;
    wire [12:0]one_pixel_index;
    wire one_sending_pixels;
    wire [15:0]one_oled_data;

<<<<<<< HEAD
    // Connect arithmetic keypad renderer to first OLED
//    arithmetic_keypad_renderer keypad_renderer(
//        .clk(clk_6p25MHz),
//        .pixel_index(one_pixel_index),
//        .cursor_row_keypad(cursor_row_keypad),
//        .cursor_col_keypad(cursor_col_keypad),
//        .cursor_row_operand(cursor_row_operand),
//        .cursor_col_operand(cursor_col_operand),
//        .has_decimal(has_decimal),
//        .is_operand_mode(is_operand_mode),
//        .oled_data(one_oled_data)
//    );

=======
>>>>>>> project-weihao
    Oled_Display first_display(
        .clk(clk_6p25MHz),
        .reset(0),
        .frame_begin(one_frame_begin),
        .sending_pixels(one_sending_pixels),
        .sample_pixel(one_sample_pixel),
        .pixel_index(one_pixel_index),
        .pixel_data(one_oled_data),
        .cs(JB[0]), 
        .sdin(JB[1]), 
        .sclk(JB[3]), 
        .d_cn(JB[4]), 
        .resn(JB[5]), 
        .vccen(JB[6]),
        .pmoden(JB[7])
    );
    
<<<<<<< HEAD
//    // Second OLED display unit (to render outputs)
//    wire two_frame_begin;
//    wire two_sample_pixel;
//    wire [12:0]two_pixel_index;
//    wire two_sending_pixels;
//    wire [15:0]two_oled_data;

//    // Connect result renderer to second OLED
//    arithmetic_result_renderer result_renderer(
//        .clk(clk_6p25MHz),
//        .pixel_index(two_pixel_index),
//        .result(result),
//        .is_operand_mode(is_operand_mode),
//        .oled_data(two_oled_data)
//    );

//    Oled_Display second_display(
//        .clk(clk_6p25MHz),
//        .reset(0),
//        .frame_begin(two_frame_begin),
//        .sending_pixels(two_sending_pixels),
//        .sample_pixel(two_sample_pixel),
//        .pixel_index(two_pixel_index),
//        .pixel_data(two_oled_data),
//        .cs(JA[0]), 
//        .sdin(JA[1]), 
//        .sclk(JA[3]), 
//        .d_cn(JA[4]), 
//        .resn(JA[5]), 
//        .vccen(JA[6]),
//        .pmoden(JA[7])
//    );
    
    main_menu mm(btnC, btnU, btnD, btnL, btnR, basys_clock, one_pixel_index, seg, one_oled_data, an);
=======
    
    // 25MHz clock for screen display
    wire clk_25MHz;
    flexible_clock_divider clk_25MHz_gen(
        .main_clock(basys_clock),
        .ticks(7),
        .output_clock(clk_25MHz)
    );
    
   wire [5:0] character;
   assign character = sw[5:0];
   wire [15:0] colour;
   assign colour = {  {5{sw[15]}}, {6{sw[14]}}, {5{sw[13]}}  };
    
    // Declare wires for active pixels and their corresponding colors for each number/sprite
    wire [15:0] number1_color, number2_color, number3_color;
    wire number1_active, number2_active, number3_active;
    
    //Position of strings
    reg [7:0]posXOne = 15;
    reg [7:0]posYOne = 40;
    reg [7:0]posXTwo = 70;
    reg [7:0]posYTwo = 40;
    reg [7:0]posXThree = 15;
    reg [7:0]posYThree = 20;
            
    // Instantiate number sprites at different positions
    string_renderer result (
        .clk(clk_25MHz),
        .pixel_index(one_pixel_index),
        .word(48'b100000_010011_100001_100011_011010_100010_101001_111111),
        .start_x(posXOne), // X position
        .start_y(posYOne), // Y position
        .colour(colour), // Colour (e.g., red)
        .oled_data(number1_color),
        .active_pixel(number1_active)
    );

    sprite_renderer number2 (
        .clk(clk_25MHz),
        .pixel_index(one_pixel_index),
        .character(character), 
        .start_x(posXTwo), 
        .start_y(posYTwo),
        .colour(colour), 
        .oled_data(number2_color),
        .active_pixel(number2_active)
    );
    
    string_renderer number3 (
        .clk(clk_25MHz),
        .pixel_index(one_pixel_index),
        .word(48'b000100_001011_000010_111111_111111_111111_111111_111111), 
        .start_x(posXThree), 
        .start_y(posYThree),
        .colour(colour), 
        .oled_data(number3_color),
        .active_pixel(number3_active)
    );

    // Combine the pixel data from all sprites
    assign one_oled_data = number1_active ? number1_color :
                           number2_active ? number2_color :
                           number3_active ? number3_color :
                           16'hFFFF; // Background
                  
    reg prevBtnU = 0;
    reg prevBtnD = 0;
    reg prevBtnL = 0;
    reg prevBtnR = 0;
    reg prevBtnC = 0;
    
    reg [2:0] charSelect = 0;
    
    
            
    always @ (posedge clk_25MHz) begin
        if (prevBtnC & ~btnC) begin
            charSelect = (charSelect == 2)? 0 : charSelect+1;
        end
        
        if (prevBtnU & ~btnU) begin
            case (charSelect)
                2'b00: posYOne <= (posYOne<5)? 0 : posYOne-5;
                2'b01: posYTwo <= (posYTwo<5)? 0 : posYTwo-5;
                2'b10: posYThree <= (posYThree<5)? 0 : posYThree-5;
             endcase
        end
        
        if (prevBtnD & ~btnD) begin
            case (charSelect)
                2'b00: posYOne <= (posYOne>55)? 60 : posYOne+5;
                2'b01: posYTwo <= (posYTwo>55)? 60 : posYTwo+5;
                2'b10: posYThree <= (posYThree>55)? 60 : posYThree+5;
            endcase
        end
        
        if (prevBtnL & ~btnL) begin
           case (charSelect)
                2'b00: posXOne <= (posXOne<5)? 0 : posXOne-5;
                2'b01: posXTwo <= (posXTwo<5)? 0 : posXTwo-5;
                2'b10: posXThree <= (posXThree<5)? 0 : posXThree-5;
           endcase  
        end
        
        if (prevBtnR & ~btnR) begin
            case (charSelect)
                2'b00: posXOne <= (posXOne>85)? 90 : posXOne+5;
                2'b01: posXTwo <= (posXTwo>85)? 90 : posXTwo+5;
                2'b10: posXThree <= (posXThree>85)? 90 : posXThree+5;
            endcase
        end
        
        prevBtnU <= btnU;
        prevBtnD <= btnD;
        prevBtnL <= btnL;
        prevBtnR <= btnR;
        
        prevBtnC <= btnC;
    end

>>>>>>> project-weihao

endmodule