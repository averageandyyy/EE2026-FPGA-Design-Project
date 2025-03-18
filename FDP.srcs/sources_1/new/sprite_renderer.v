module sprite_renderer(
    input clk,
    
    //Pixel in consideration
    input [12:0] pixel_index, 
    
    // Character to render
    input [5:0] character,
    
    //Coordinates of character        
    input [6:0] start_x,       
    input [5:0] start_y,    
    input [15:0] colour,
//    output reg [15:0] led,
    output reg [15:0] oled_data, // OLED pixel data output
    output reg active_pixel      // New output for active pixel
);

    parameter WIDTH = 96;   // Display width
    parameter HEIGHT = 64;  // Display height
    parameter CHAR_WIDTH = 8;
    parameter CHAR_HEIGHT = 12;

    // Determine pixel coordinates from the linear pixel index
    wire [6:0] x = pixel_index % WIDTH;
    wire [5:0] y = pixel_index / WIDTH;

    // Variables for the current character being rendered
    wire [7:0] pixel_row;
    
//    reg [2:0] column = 0;
//    reg [3:0] row = 0;
    
//    wire [3:0] row = y - start_y;
//    wire [2:0] column = x - start_x;

   wire [3:0] row = y - start_y;
   wire [2:0] column = start_x - x;   

    // Instantiate the font ROM
    number_sprites number(
        .character(character),
        .row(row),
        .pixels(pixel_row)
    );

    always @(posedge clk) begin
        // White background
        oled_data <= 16'b11111_111111_11111;
        active_pixel <= 0;
  
        // Check if the pixel lies within the character's bounds
        if (x <= start_x && x > (start_x - CHAR_WIDTH) && y >= start_y && y < (start_y + CHAR_HEIGHT)) begin

            // Check pixel ON/OFF from the character sprite ROM
            if (pixel_row[column]) begin
                // Set pixel based on provided colour
                oled_data <= colour;  
                // Mark this as an active pixel
                active_pixel <= 1; 
            end
        end 
    end
endmodule
