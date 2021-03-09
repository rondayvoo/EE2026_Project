`timescale 1ns / 1ps

module volumebar (
    input CLK100MHZ,
    input [15:0] sw,
    //sw[3] toggles beween a 1 px white border and a 3 px white border
    //sw[4] hides border
    //sw[5] toggles color scheme
    //sw[6] hides volume bar
    input btnC,
    input btnD,
    input btnL,
    input btnR,
    input btnU,
    //btnL moves the bar to the left
    //btnR moves the bar to the right
    input [3:0] volave,
    output [0:7] JC //Port JC for display
    );
    
    reg [19:0] ctr21 = 0;
    wire dbounceC;
    wire dbounceD;
    wire dbounceL;
    wire dbounceR;
    wire dbounceU;
    
    reg [2:0] ctr6p25m = 0;
    reg clk6p25m = 0;
    wire reset;
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [12:0] pixel_index;
    reg [15:0] oled_data = 16'h07E0;
    
    reg [6:0] xpointer;
    reg [5:0] ypointer;
    wire [12:0] xyconvert;
    
    reg [15:0] colorGreen = 16'h07E0;
    reg [15:0] colorYellow = 16'hFCF8;
    reg [15:0] colorRed = 16'hF411;
    reg [15:0] colorWhite = 0;
    reg [15:0] colorBlack = 16'hFFFF;
    
    SPO dbC(CLK100MHZ, ctr21[20], btnC, dbounceC);
    SPO dbD(CLK100MHZ, ctr21[20], btnD, dbounceD);
    SPO dbL(CLK100MHZ, ctr21[20], btnL, dbounceL);
    SPO dbR(CLK100MHZ, ctr21[20], btnR, dbounceR);
    SPO dbU(CLK100MHZ, ctr21[20], btnU, dbounceU);
    
    Oled_Display display(clk6p25m, reset, frame_begin, sending_pixels, sample_pixel, pixel_index, oled_data,
                         JC[0], JC[1], JC[3], JC[4], JC[5], JC[6], JC[7]);
    Coordinate_Converter point(xpointer, ypointer, xyconvert);
    
    always @ (posedge CLK100MHZ) begin
        ctr21 <= ctr21 + 1;
        ctr6p25m <= ctr6p25m + 1;                        
        clk6p25m <= ctr6p25m == 0 ? ~clk6p25m : clk6p25m;
    end
endmodule