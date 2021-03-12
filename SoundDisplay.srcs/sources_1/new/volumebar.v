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
    //input [3:0] volume,
    output [0:7] JDisplay //Port JB for display
    );
    
    reg [20:0] ctr21 = 0;
    wire dbounceC;
    wire dbounceD;
    wire dbounceL;
    wire dbounceR;
    wire dbounceU;
    
    reg [2:0] ctr6p25m = 0;
    reg clk6p25m = 0;
    reg [15:0] oled_data = 0;
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [12:0] pixel_index;
    wire [4:0] teststate;
    
    wire [6:0] xpoint;
    wire [5:0] ypoint;
    reg [3:0] barxpos = 7;
    reg [3:0] volume = 0;
    
    reg [15:0] colorPink = 16'hC819;
    reg [15:0] colorViolet = 16'h5031;
    reg [15:0] colorBlue = 16'h067E;
    reg [15:0] colorGreen = 16'h07E0;
    reg [15:0] colorYellow = 16'hF6C9;
    reg [15:0] colorRed = 16'hF0C3;
    reg [15:0] colorWhite = 16'hFFFF;
    reg [15:0] colorBlack = 0;
    
    SPO dbC(ctr21[20], btnC, dbounceC);
    SPO dbD(ctr21[20], btnD, dbounceD);
    SPO dbL(ctr21[20], btnL, dbounceL);
    SPO dbR(ctr21[20], btnR, dbounceR);
    SPO dbU(ctr21[20], btnU, dbounceU);
    
    Oled_Display d0(clk6p25m, dbounceC, frame_begin, sending_pixels, sample_pixel, pixel_index, oled_data,
                    JDisplay[0], JDisplay[1], JDisplay[3], JDisplay[4], JDisplay[5], JDisplay[6], JDisplay[7], teststate);
    Coordinate_Converter p0(pixel_index, xpoint, ypoint);
    
    always @ (posedge CLK100MHZ) begin
        ctr21 <= ctr21 + 1;
        ctr6p25m <= ctr6p25m + 1;                        
        clk6p25m <= ctr6p25m == 0 ? ~clk6p25m : clk6p25m;
    end
    
    always @ (posedge ctr21[20]) begin
        if (dbounceU) begin
            volume <= volume + 1;
        end
        
        if (dbounceD) begin
            volume <= volume - 1;
        end
        
        if (dbounceL && barxpos > 0) begin      
            barxpos <= barxpos - 1;
        end 
        
        if (dbounceR && barxpos < 14) begin      
            barxpos <= barxpos + 1;
        end                                        
    end
    
    always @ (posedge clk6p25m) begin  
        //Volume bar     
        if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
            ypoint >= 53 && ypoint <= 54 && volume >= 0 && !sw[6]) begin
            oled_data <= sw[5] ? colorBlue : colorGreen;
        end
        
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 50 && ypoint <= 51 && volume >= 1 && !sw[6]) begin
            oled_data <= sw[5] ? colorBlue : colorGreen;                                                      
        end 
        
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 47 && ypoint <= 48 && volume >= 2 && !sw[6]) begin
            oled_data <= sw[5] ? colorBlue : colorGreen;                                                      
        end 
        
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 44 && ypoint <= 45 && volume >= 3 && !sw[6]) begin
            oled_data <= sw[5] ? colorBlue : colorGreen;                                                      
        end                                                                               
        
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 41 && ypoint <= 42 && volume >= 4 && !sw[6]) begin
            oled_data <= sw[5] ? colorBlue : colorGreen;                                                      
        end                                                                               
        
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 38 && ypoint <= 39 && volume >= 5 && !sw[6]) begin
            oled_data <= sw[5] ? colorBlue : colorGreen;                                                      
        end                                                                               
        
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 35 && ypoint <= 36 && volume >= 6 && !sw[6]) begin
            oled_data <= sw[5] ? colorViolet : colorYellow;                                                      
        end  
        
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 32 && ypoint <= 33 && volume >= 7 && !sw[6]) begin
            oled_data <= sw[5] ? colorViolet : colorYellow;                                                      
        end                                                                               
                                                                                      
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 29 && ypoint <= 30 && volume >= 8 && !sw[6]) begin                                                                              
            oled_data <= sw[5] ? colorViolet : colorYellow;                                                                                                                                    
        end                                                                                                                                                             
                                                                                      
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 26 && ypoint <= 27 && volume >= 9 && !sw[6]) begin                                                                              
            oled_data <= sw[5] ? colorViolet : colorYellow;                                                                                                                                    
        end  
        
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 23 && ypoint <= 24 && volume >= 10 && !sw[6]) begin
            oled_data <= sw[5] ? colorViolet : colorYellow;                                                          
        end      
        
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 20 && ypoint <= 21 && volume >= 11 && !sw[6]) begin
            oled_data <= sw[5] ? colorPink : colorRed;                                                                                                                                        
        end 
        
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 17 && ypoint <= 18 && volume >= 12 && !sw[6]) begin
            oled_data <= sw[5] ? colorPink : colorRed;                                                             
        end   
        
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 14 && ypoint <= 15 && volume >= 13 && !sw[6]) begin
            oled_data <= sw[5] ? colorPink : colorRed;                                                             
        end   
        
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 11 && ypoint <= 12 && volume >= 14 && !sw[6]) begin
            oled_data <= sw[5] ? colorPink : colorRed;                                                             
        end 
        
        else if (xpoint >= 43 + (barxpos - 7) * 5 && xpoint <= 51 + (barxpos - 7) * 5 && 
                 ypoint >= 8 && ypoint <= 9 && volume >= 15 && !sw[6]) begin
            oled_data <= sw[5] ? colorPink : colorRed;                                                             
        end 
        
        //Screen borders
        else if (!(xpoint >= 1 && xpoint <= 94 && 
                 ypoint >= 1 && ypoint <= 62) && !sw[4] && !sw[3]) begin
            oled_data <= colorWhite;
        end 
        
        else if (!(xpoint >= 3 && xpoint <= 92 && 
                 ypoint >= 3 && ypoint <= 60) && !sw[4] && sw[3]) begin
            oled_data <= colorWhite;
        end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
        
        else begin
            oled_data <= 0;
        end
    end
endmodule