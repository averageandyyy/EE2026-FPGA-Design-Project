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


module basic_task_c (input basys_clock, input btnC, output [7:0]JB, output reg [5:0]led);
    wire clock_25MHz;
    
    flexible_clock_divider update_clock (.main_clock(basys_clock), .ticks(1), .output_clock(clock_25MHz));
    
    wire clock_6p25MHz;
    flexible_clock_divider oled_clock (.main_clock(basys_clock), .ticks(7), .output_clock(clock_6p25MHz));
    
    wire clock_45px_persecond;
    flexible_clock_divider clock_unit_0 (.main_clock(basys_clock), .ticks(1111110), .output_clock(clock_45px_persecond));
    
    wire clock_15px_persecond;
    flexible_clock_divider clock_unit_1 (.main_clock(basys_clock), .ticks(3333332), .output_clock(clock_15px_persecond));
    
    wire clock_1kHz;
    flexible_clock_divider clock_unit_2 (.main_clock(basys_clock), .ticks(3333332), .output_clock(clock_1kHz));
    
    
        
    wire frame_begin, sending_pixels, sample_pixel;
    wire [12:0] pixel_index;
    reg [15:0] pixel_data = 16'b00000_111111_00000;
    
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
    
    always @ (posedge clock_25MHz) begin
    
        //Initialise the entire OLED
        pixel_data <= black;
        //Initialise the first square
        if( 
            (  (pos_x >= (max_x-box_width)) && (pos_x < max_x)  )         &
            (  (pos_y >= 0)          && (pos_y < box_width)  )
        ) begin
            pixel_data <= orange;
            led[0] <= 1;
        end
        
        //If center pushbutton is pressed
        if (start) begin
            //Phase 0
            if( 
                (  (pos_x >= (max_x-box_width)) && (pos_x < max_x)  )         &
                (  (pos_y >= 0)          && (pos_y < desired_y0)  )
            ) begin
                pixel_data <= orange;
                led[0] <= 1;
            end
        end
        
        //Phase 1
        if( 
            (  (pos_x >= desired_x1) && (pos_x < (max_x-box_width))  ) && 
            (  (pos_y >= (max_y-box_width) ) && (pos_y < max_y)  )
        ) begin
            pixel_data <= orange;
            led[1] <= 1;            
        end 
        
        //Phase 2
        if( 
            (  (pos_x >= (max_x/2 - box_width/2)) && (pos_x < (max_x/2 - box_width/2) + box_width)  ) && 
            (  (pos_y >= desired_y2) && (pos_y < max_y-box_width)  )
        ) begin
            pixel_data <= orange;
            led[2] <= 1;            
        end 
        
        //Phase 3
        if( 
            (  (pos_x >= (max_x/2 - box_width/2 + box_width) ) && (pos_x < (desired_x3))  ) && 
            (  (pos_y >= (max_y/2 - box_width/2)) && (pos_y < ((max_y/2 - box_width/2))+box_width)  )
        ) begin
            pixel_data <= orange;
            led[2] <= 1;            
        end 
        
        //Phase 4
        if( 
            (  (pos_x >= (max_x *3/4 + box_width/2 - box_width)) && (pos_x < (max_x *3/4 + box_width/2))  ) && 
            (  (pos_y >= (desired_y4)) && (pos_y < (max_y/2 - box_width/2))  )
        ) begin
            pixel_data <= orange;
            led[2] <= 1;            
        end 
        
        //Phase 5
        if( 
            (  (pos_x >= (max_x *3/4 + box_width/2)) && (pos_x < (desired_x5))  ) && 
            (  (pos_y >= 0) && (pos_y < box_width)  )
        ) begin
            pixel_data <= orange;
            led[2] <= 1;            
        end 
        
    end

    
    always @ (posedge clock_45px_persecond)
    begin
        if (start)
        begin
            if (desired_y0 < max_y)
            begin
                desired_y0 <= desired_y0 + 1;
                led[3] <= 1;
            end
            else 
            begin
                phase1 <= 1;
            end 
        end
        else begin
            //phase1 <= 0;
            //phase2 <= 0;
        end
        

        if (phase1)
        begin
            if (desired_x1 > (max_x/2 - box_width/2) )
            begin 
                led[4] <= 1;
                desired_x1 <= desired_x1 - 1;
            end
            else 
            begin
                phase2 <= 1;
            end 
        end 
 
    end
    
    always @ (posedge clock_15px_persecond)
    begin
        if (phase2)
        begin
            if (desired_y2 > (max_y/2 - box_width/2) )
            begin 
                led[5] <= 1;
                desired_y2 <= desired_y2 - 1;
            end
            else 
            begin
                phase3 <= 1;
            end 
        end 
        
        if (phase3)
        begin
            if (desired_x3 < (max_x *3/4 + box_width/2) )
            begin 
                //led[5] <= 1;
                desired_x3 <= desired_x3 + 1;
            end
            else 
            begin
                phase4 <= 1;
            end 
        end 
        
        if (phase4)
        begin
            if (desired_y4 > 0)
            begin 
                //led[5] <= 1;
                desired_y4 <= desired_y4 - 1;
            end
            else 
            begin
                phase5 <= 1;
            end 
        end 
        
        if (phase5)
        begin
            if (desired_x5 < max_x-box_width)
            begin 
                //led[5] <= 1;
                desired_x5 <= desired_x5 + 1;
            end
            else 
            begin
                //start <= 0;
                //phase3 <= 0;
               // phase4 <= 0;
               // phase5 <= 0;
                
            end 
        end 
    end
    
    reg prev_btn;
    reg start = 0;
    reg reset = 0;
    always @ (posedge clock_1kHz) begin
        if (prev_btn & ~btnC) begin            
//            if (reset == 1) begin
//                //start <= 0;
//            end
//            else begin
                start <= 1;
            //end
        end

        
//        if (desired_x5 == max_x-box_width) begin
//            reset <= 1;
//        end
        prev_btn <= btnC;    
    end
    
    
endmodule