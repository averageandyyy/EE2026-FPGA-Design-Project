module sprite_renderer(
    input clk,
    input [12:0] pixel_index, // pixel index in the overall display
    input [3:0] digit,         // an array of 8 characters to render
    input [6:0] start_x,       // starting x position of the text block
    input [5:0] start_y,       // starting y position of the text block
    input [15:0] colour,
    output reg [15:0] led,
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

    reg [3:0] row;
    reg [2:0] column;

    // Instantiate the font ROM
    number_sprites number(
        .number(digit),
        .row(row),
        .pixels(pixel_row)
    );

    always @(posedge clk) begin
        // Default background: white
        oled_data <= 16'b11111_111111_11111;
        active_pixel = 0;
        //led[3] = 1;
  
        // Check if the pixel (x, y) lies within the current character's bounds
        if (x <= start_x && x > (start_x - CHAR_WIDTH) && y >= start_y && y < (start_y + CHAR_HEIGHT)) begin
            row = y - start_y;
            column = start_x - x;
            
            // Calculate the corresponding pixel in the character's sprite (row/column)
            //led[4] = 1;
            //oled_data <= 16'b00000_000000_11111;

            // Get the pixel value from the sprite ROM
            if (pixel_row[column]) begin
                //led[5] = 1;
                oled_data <= colour;  // Set the pixel color to the provided colour
                active_pixel = 1;    // Mark this as an active pixel
//            end else begin
//                oled_data <= 16'b00000_000000_00000;  // Set the pixel color to the provided colour
//                active_pixel = 1;   
            end
        end 
    end
endmodule
