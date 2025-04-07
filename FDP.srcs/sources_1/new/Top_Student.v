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
    output [6:0] seg,
    output [3:0] an,
    inout  wire        ps2_clk,     // PS/2 clock line
    inout  wire        ps2_data     // PS/2 data line
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
    
    // First OLED display unit
    wire one_frame_begin;
    wire one_sample_pixel;
    wire [12:0]JB_pixel_index;
    wire one_sending_pixels;
    wire [15:0]JB_oled_data;

    // Second OLED display unit
    wire two_frame_begin;
    wire two_sample_pixel;
    wire [12:0]JA_pixel_index;
    wire two_sending_pixels;
    wire [15:0]JA_oled_data;
    
//    // System control signals
//    wire reset = sw[15];                   // Use SW15 for reset
//    wire is_arithmetic_mode = sw[0]; // 1'b1;        // Always enabled for arithmetic testing
//    wire is_table_mode = sw[1];             // Disabled for testing
//    wire is_integral_mode = sw[2];
    
//    // Mouse placeholder signals (not used for testing)
//    wire [6:0] mouse_x = 0;
//    wire [6:0] mouse_y = 0;
//    wire mouse_left = 0;
//    wire mouse_middle = 0;

//    // Output data from both modules
//    wire [15:0] arith_one_oled_data;
//    wire [15:0] arith_two_oled_data;
//    wire [15:0] poly_one_oled_data;
//    wire [15:0] poly_two_oled_data;
//    wire [15:0] integral_one_oled_data;
//    wire [15:0] integral_two_oled_data;
    
//    // Default polynomial coefficients (when not connected to actual inputs)
//    wire signed [31:0] coeff_a = 32'h00010000; // 1.0 in fixed-point
//    wire signed [31:0] coeff_b = 32'h00010000; // 1.0 in fixed-point
//    wire signed [31:0] coeff_c = 32'h00010000; // 1.0 in fixed-point
//    wire signed [31:0] coeff_d = 32'h00000000; // 0.0 in fixed-point

//    // ARITHMETIC MODULE - Connected to OLED for testing
//    arithmetic_module arithmetic(
//        .clk_6p25MHz(clk_6p25MHz),
//        .clk_1kHz(clk_1kHz),
//        .btnC(btnC),
//        .btnU(btnU),
//        .btnD(btnD),
//        .btnL(btnL),
//        .btnR(btnR),
//        .reset(reset),
//        .is_arithmetic_mode(is_arithmetic_mode),
//        .xpos(mouse_x),
//        .ypos(mouse_y),
//        .use_mouse(1'b0),                  // Disable mouse for testing
//        .mouse_left(mouse_left),
//        .mouse_middle(mouse_middle),
//        .one_pixel_index(JB_pixel_index),
//        .two_pixel_index(JA_pixel_index),
//        .one_oled_data(arith_one_oled_data),
//        .two_oled_data(arith_two_oled_data)
//    );

//    // POLYNOMIAL TABLE MODULE - Instantiated but not connected to OLED
//    polynomial_table_module polynomial_table(
//        .clk_6p25MHz(clk_6p25MHz),
//        .clk_1kHz(clk_1kHz),
//        .clk_100MHz(basys_clock),
//        .btnC(btnC),
//        .btnU(btnU),
//        .btnD(btnD),
//        .btnL(btnL),
//        .btnR(btnR),
//        .xpos(mouse_x),
//        .ypos(mouse_y),
//        .use_mouse(1'b0),                  // Disable mouse
//        .mouse_left(mouse_left),
//        .mouse_middle(mouse_middle),
//        .is_table_mode(is_table_mode),     // Disabled - set to 0
//        .coeff_a(coeff_a),
//        .coeff_b(coeff_b),
//        .coeff_c(coeff_c),
//        .coeff_d(coeff_d),
//        .one_pixel_index(JB_pixel_index),
//        .two_pixel_index(JA_pixel_index),
//        .one_oled_data(poly_one_oled_data),
//        .two_oled_data(poly_two_oled_data)
//    );

//    // INTEGRAL MODULE
//    integral_module integral(
//        .clk_6p25MHz(clk_6p25MHz),
//        .clk_1kHz(clk_1kHz),
//        .btnC(btnC),
//        .btnU(btnU),
//        .btnD(btnD),
//        .btnL(btnL),
//        .btnR(btnR),
//        .reset(reset),
//        .is_integral_mode(is_integral_mode),
//        .coeff_a(coeff_a),
//        .coeff_b(coeff_b),
//        .coeff_c(coeff_c),
//        .coeff_d(coeff_d),
//        .one_pixel_index(JB_pixel_index),
//        .two_pixel_index(JA_pixel_index),
//        .one_oled_data(integral_one_oled_data),
//        .two_oled_data(integral_two_oled_data)
//    );

//    // Connect arithmetic module outputs to OLED displays during testing
//    assign JB_oled_data = integral_one_oled_data;
//    assign JA_oled_data = integral_two_oled_data;

    // OLED display connections
    Oled_Display first_display(
        .clk(clk_6p25MHz),
        .reset(0),
        .frame_begin(one_frame_begin),
        .sending_pixels(one_sending_pixels),
        .sample_pixel(one_sample_pixel),
        .pixel_index(JB_pixel_index),
        .pixel_data(JB_oled_data),
        .cs(JB[0]), 
        .sdin(JB[1]), 
        .sclk(JB[3]), 
        .d_cn(JB[4]), 
        .resn(JB[5]), 
        .vccen(JB[6]),
        .pmoden(JB[7])
    );
    
    Oled_Display second_display(
        .clk(clk_6p25MHz),
        .reset(0),
        .frame_begin(two_frame_begin),
        .sending_pixels(two_sending_pixels),
        .sample_pixel(two_sample_pixel),
        .pixel_index(JA_pixel_index),
        .pixel_data(JA_oled_data),
        .cs(JA[0]), 
        .sdin(JA[1]), 
        .sclk(JA[3]), 
        .d_cn(JA[4]), 
        .resn(JA[5]), 
        .vccen(JA[6]),
        .pmoden(JA[7])
    );

//    // Basic LED indicators
//    assign led[0] = is_arithmetic_mode;    // Arithmetic mode active
//    assign led[1] = is_table_mode;         // Table mode
//    assign led[2] = is_integral_mode;      // Integral mode active
//    assign led[15] = reset;                // Reset status

    main_menu mm(.btnC(btnC), .btnU(btnU), .btnD(btnD), .btnL(btnL), .btnR(btnR), // push-buttons
    .basys_clock(basys_clock),
    .pixel_index_1(JB_pixel_index), .pixel_index_2(JA_pixel_index),
    .sw(sw),
    .seg(seg), // 7-segment display
    .oled_data_1(JB_oled_data), .oled_data_2(JA_oled_data), // OLED output
    .an(an));
endmodule