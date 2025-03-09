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


module basic_task_c (input basys_clock, input btnC, output [7:0]JB, output [7:0]led);
    wire clock_25MHz;
    
    flexible_clock_divider update_clock (.main_clock(basys_clock), .ticks(1), .output_clock(clock_25MHz));
    
    wire clock_6p25MHz;
    flexible_clock_divider oled_clock (.main_clock(basys_clock), .ticks(7), .output_clock(clock_6p25MHz));
    
    wire clock_45px_persecond;
    flexible_clock_divider clock_unit_0 (.main_clock(basys_clock), .ticks(1111110), .output_clock(clock_45px_persecond));
    
    wire clock_15px_persecond;
    flexible_clock_divider clock_unit_1 (.main_clock(basys_clock), .ticks(3333332), .output_clock(clock_15px_persecond));
    
    wire clock_1kHz;
    flexible_clock_divider clock_unit_2 (.main_clock(basys_clock), .ticks(49999), .output_clock(clock_1kHz));
    
    //For resetting
    reg prev_btn;
    reg start = 0;
    reg end_flag = 0;
    reg reset_flag = 0;
        
    wire frame_begin, sending_pixels, sample_pixel;
    wire [12:0] pixel_index;
    reg [15:0] pixel_data;
    
    Oled_Display display_unit(
        .clk(clock_6p25MHz), 
        .reset(0), 
        .frame_begin(frame_begin), 
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel), 
        .pixel_index(pixel_index), 
        .pixel_data(pixel_data), 
        .cs(JB[0]), 
        .sdin(JB[1]), 
        .sclk(JB[3]), 
        .d_cn(JB[4]), 
        .resn(JB[5]), 
        .vccen(JB[6]),
        .pmoden(JB[7])
    ); 
    
    //Define oled parameters
    localparam [7:0]max_x = 96;
    localparam [7:0]max_y = 64;
    
    //Fixed square width
    localparam [3:0]box_width = 11;
    
    //Define colours
    wire [15:0]orange = 16'b11111_100000_00000;
    wire [15:0]black = {16{1'b0}};
    
    wire  [31:0]pos_x;
    wire  [31:0]pos_y;
    assign pos_x = pixel_index % 96;
    assign pos_y = pixel_index / 96;
    
    //reg start = 0; // to be connected to pushbutton
    reg [7:0]desired_y0 = box_width;
    
    reg phase1 = 0;
    reg [7:0]desired_x1 = max_x-box_width;
    
    reg phase2 = 0;
    reg [7:0]desired_y2 = max_y-box_width;
    
    reg phase3 = 0;
    reg [7:0]desired_x3 = (max_x/2 - box_width/2) + box_width;
    
    reg phase4 = 0;
    reg [7:0]desired_y4 = max_y/2 - box_width/2;
    
    reg phase5 = 0;
    reg [7:0]desired_x5 = (max_x *3/4 + box_width/2);   
    
    assign led[0] = start;
    assign led[1] = end_flag;
    assign led[2] = reset_flag;
    assign led[3] = phase1;
    assign led[4] = phase2;
    assign led[5] = phase3;
    assign led[6] = (desired_x5 == max_x - box_width);
    assign led[7] = phase5;    
    
    always @ (posedge clock_25MHz) begin
        //Initialise the entire OLED
        pixel_data <= black;
        
        //No start           
        if (!start) begin
            
            //Initialise the first square
            if( 
                (  (pos_x >= (max_x-box_width)) && (pos_x < max_x)  )         &&
                (  (pos_y >= 0)          && (pos_y < box_width)  )
            ) begin
                pixel_data <= orange;
           end
        end
        
        //If center pushbutton is pressed
        if (start) begin
            //Phase 0
            if( 
                (  (pos_x >= (max_x-box_width)) && (pos_x < max_x)  )         &&
                (  (pos_y >= 0)          && (pos_y < desired_y0)  )
            ) begin
                pixel_data <= orange;
                
            end
            
            //Phase 1
            if( 
                (  (pos_x >= desired_x1) && (pos_x < (max_x-box_width))  ) && 
                (  (pos_y >= (max_y-box_width) ) && (pos_y < max_y)  )
            ) begin
                pixel_data <= orange;       
            end 
            
            //Phase 2
            if( 
                (  (pos_x >= (max_x/2 - box_width/2)) && (pos_x < (max_x/2 - box_width/2) + box_width)  ) && 
                (  (pos_y >= desired_y2) && (pos_y < max_y-box_width)  )
            ) begin
                pixel_data <= orange;       
            end 
            
            //Phase 3
            if( 
                (  (pos_x >= (max_x/2 - box_width/2 + box_width) ) && (pos_x < (desired_x3))  ) && 
                (  (pos_y >= (max_y/2 - box_width/2)) && (pos_y < ((max_y/2 - box_width/2))+box_width)  )
            ) begin
                pixel_data <= orange;        
            end 
            
            //Phase 4
            if( 
                (  (pos_x >= (max_x *3/4 + box_width/2 - box_width)) && (pos_x < (max_x *3/4 + box_width/2))  ) && 
                (  (pos_y >= (desired_y4)) && (pos_y < (max_y/2 - box_width/2))  )
            ) begin
                pixel_data <= orange;         
            end 
            
            //Phase 5
            if( 
                (  (pos_x >= (max_x *3/4 + box_width/2)) && (pos_x < (desired_x5))  ) && 
                (  (pos_y >= 0) && (pos_y < box_width)  )
            ) begin
                pixel_data <= orange;      
            end 
        end
    end

    
    always @ (posedge clock_45px_persecond)
    begin
        if (start) begin
            if (desired_y0 < max_y) begin
                desired_y0 <= desired_y0 + 1;
            end
            else begin
                phase1 <= 1;
            end 
        end  
        else 
        phase1 <= 0;      

        if (phase1) begin
            if (desired_x1 > (max_x/2 - box_width/2) ) begin 
                desired_x1 <= desired_x1 - 1;
            end
            else begin
                phase2 <= 1;
            end 
        end 
        else
        phase2 <= 0;
    end
    
    always @ (posedge clock_15px_persecond) begin
        if (phase2) begin
            if (desired_y2 > (max_y/2 - box_width/2) ) begin 
                desired_y2 <= desired_y2 - 1;
            end
            else begin
                phase3 <= 1;
            end 
        end 
        
        if (phase3) begin
            if (desired_x3 < (max_x *3/4 + box_width/2) ) begin 
                desired_x3 <= desired_x3 + 1;
            end
            else begin
                phase4 <= 1;
            end 
        end 
        
        if (phase4) begin
            if (desired_y4 > 0) begin 
                desired_y4 <= desired_y4 - 1;
            end
            else begin
                phase5 <= 1;
            end 
        end 
        
        if (phase5) begin
            if (desired_x5 < max_x-box_width) begin
                desired_x5 <= desired_x5 + 1;
            end
            else begin
                end_flag <= 1;
            end 
        end 
    end
    
    
    always @ (posedge clock_1kHz) begin
        if (prev_btn && !btnC) begin // Detect button press
            if (end_flag) begin
                start <= 0;
                reset_flag <= 1;  // Reset when animation has finished
            end else begin
                start <= 1;  // Start the animation
            end
        end
        prev_btn <= btnC; // Store previous button state
    end
    
    
endmodule