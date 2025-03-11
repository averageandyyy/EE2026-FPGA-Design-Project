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


module basic_task_c (input basys_clock, input btnC, input [12:0]pixel_index, input hasPassword, output reg [15:0]pixel_data); 
    //Refresh frame rate
    wire clock_25MHz;    
    flexible_clock_divider update_clock (.main_clock(basys_clock), .ticks(1), .output_clock(clock_25MHz));
    
    //Square movement rate
    wire clock_45px_persecond;
    flexible_clock_divider clock_unit_0 (.main_clock(basys_clock), .ticks(1111110), .output_clock(clock_45px_persecond));
    
    //For resetting
    reg prev_btn = 0;
    reg start_flag = 0;
    reg end_flag = 0;
    
    //Define oled parameters
    localparam [7:0]max_x = 96;
    localparam [7:0]max_y = 64;
    
    //Fixed square width
    localparam [3:0]box_width = 11;
    
    //Define colours
    wire [15:0]orange = 16'b11111_100000_00000;
    wire [15:0]black = {16{1'b0}};
    
    //Pixel position
    wire  [31:0]pos_x;
    wire  [31:0]pos_y;
    assign pos_x = pixel_index % 96;
    assign pos_y = pixel_index / 96;
    
    //Phase 0 parameters
    reg [7:0]desired_y0 = box_width;
    
    //Phase 1 parameters
    reg phase1 = 0;
    reg [7:0]desired_x1 = max_x-box_width;
    
    //Phase 2 parameters
    reg phase2 = 0;
    reg [7:0]desired_y2 = max_y-box_width;
    
    //Phase 3 parameters
    reg phase3 = 0;
    reg [7:0]desired_x3 = (max_x/2 - box_width/2) + box_width;
    
    //Phase 4 parameters
    reg phase4 = 0;
    reg [7:0]desired_y4 = max_y/2 - box_width/2;
    
    //Phase 5 parameters
    reg phase5 = 0;
    reg [7:0]desired_x5 = (max_x *3/4 + box_width/2);   
    

    //For each frame, light up the specified pixels
    always @ (posedge clock_25MHz) begin
    
        //Initialise the entire OLED
        pixel_data <= black;
        
        //No start, initiliase the square          
        if (!start_flag) begin
            
            //Initialise the first square
            if( 
                (  (pos_x >= (max_x-box_width)) && (pos_x < max_x)  )         &&
                (  (pos_y >= 0)          && (pos_y < box_width)  )
            ) begin
                pixel_data <= orange;
           end
        end
        
        //If center pushbutton is pressed, start animation
        if (start_flag) begin
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
        
        //Check button press
        if (prev_btn && !btnC && hasPassword) begin 
            if (end_flag) begin
                start_flag <= 0;
            end 
            else if (!end_flag) begin
                // Start the animation
                start_flag <= 1;  
            end
        end
        // Detect button press
        if (hasPassword) begin
            prev_btn <= btnC;
        end 
        else begin
            prev_btn <= 0;
        end
        
        if (!hasPassword) begin
            start_flag <= 0;
        end

    end

    reg [1:0]count = 0;
    always @ (posedge clock_45px_persecond)
    begin
        //Update boundaries for animation
        if (start_flag) begin
            if (desired_y0 < max_y) begin
                desired_y0 = desired_y0 + 1;
            end
            else begin
                
                phase1 = 1;
            end 
              
            if (phase1) begin
                if (desired_x1 > (max_x/2 - box_width/2) ) begin 
                    desired_x1 = desired_x1 - 1;
                end
                else begin
                   //Unlock next phase
                    phase2 = 1;
                end 
            end 
            
            //Start the slower phase 2 without extra time interval
            if (phase2) begin
                //Since Phase to 5 updates at 15px per second, 3x slower, update every third count
                if (count == 0) begin
                    if (phase2) begin
                        if (desired_y2 > (max_y/2 - box_width/2) ) begin 
                            desired_y2 = desired_y2 - 1;
                        end
                        else begin
                            //Unlock next phase
                            phase3 = 1;
                        end 
                    end 
                    
                    if (phase3) begin
                        if (desired_x3 < (max_x *3/4 + box_width/2) ) begin 
                            desired_x3 = desired_x3 + 1;
                        end
                        else begin
                            //Unlock next phase
                            phase4 = 1;
                        end 
                    end 
                    
                    if (phase4) begin
                        if (desired_y4 > 0) begin 
                            desired_y4 = desired_y4 - 1;
                        end
                        else begin
                            //Unlock next phase
                            phase5 = 1;
                        end 
                    end 
                    
                    if (phase5) begin
                        if (desired_x5 < max_x-box_width) begin
                            desired_x5 = desired_x5 + 1;
                        end
                        else begin
                            //Signal animation ended
                            end_flag = 1;
                        end 
                    end 
                end
                //Count every 3 cycles for 15pxper second
                count = (count ==3)? 0: count +1;
            end
        end 
        else begin
            // Reset animation phases if start is 0
            phase1 = 0;
            phase2 = 0;
            phase3 = 0;
            phase4 = 0;
            phase5 = 0;
        
            // Reset all movement parameters to initial positions
            desired_y0 = box_width;
            desired_x1 = max_x - box_width;
            desired_y2 = max_y - box_width;
            desired_x3 = (max_x/2 - box_width/2) + box_width;
            desired_y4 = max_y / 2 - box_width / 2;
            desired_x5 = (max_x * 3 / 4 + box_width / 2);
            end_flag = 0;
        end
        
    end
    
    
endmodule