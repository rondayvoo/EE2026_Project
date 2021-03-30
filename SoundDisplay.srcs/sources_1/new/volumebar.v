`timescale 1ns / 1ps

module volumebar (
    input CLK100MHZ,
    input [11:0] mic_in,
    input [3:0] volume,
    input [15:0] sw,
    //sw[0] toggles between volume and mic_in
    //sw[1] turns on alphabet
    //sw[3] toggles beween a 1 px white border and a 3 px white border
    //sw[4] hides border
    //sw[5] toggles color scheme
    //sw[6] hides volume bar
    input btnC,
    input btnD,
    input btnL,
    input btnR,
    input btnU,
    
    input dbounceC,
    input dbounceD,
    input dbounceL,
    input dbounceR,
    input dbounceU,
    
    input [6:0] xpoint,
    input [5:0] ypoint,
    input globalreset,
    
    output reg [15:0] ledreg = 0,
    output reg [3:0] anreg = 15,
    output reg [6:0] segreg = 127,
    output reg [15:0] oled_data = 0,
    output reg [3:0] statechange = 15
    //btnL moves the bar to the left
    //btnR moves the bar to the right
    );
    
    reg [20:0] ctr21 = 0;
    reg [20:0] pausectr = 1;
    
    reg [2:0] ctr6p25m = 0;
    reg clk6p25m = 0;
    
    reg [15:0] ledpause = 0;
    reg [15:0] ledvolume = 0; 
    reg pause = 0;
    reg reset = 0;
    reg [3:0] barxpos = 7;
    reg [3:0] cursor = 0;
    reg [1:0] segdisplayctr = 0;
    
    reg [6:0] charL = 7'b1000111;
    reg [6:0] charM = 7'b1101010;
    reg [6:0] charH = 7'b0001001;
    reg [6:0] char0 = 7'b1000000;
    reg [6:0] char1 = 7'b1111001;
    reg [6:0] char2 = 7'b0100100;
    reg [6:0] char3 = 7'b0110000;
    reg [6:0] char4 = 7'b0011001;
    reg [6:0] char5 = 7'b0010010;
    reg [6:0] char6 = 7'b0000010;
    reg [6:0] char7 = 7'b1111000;
    reg [6:0] char8 = 7'b0000000;
    reg [6:0] char9 = 7'b0010000;
    
    reg [15:0] colorPink = 16'hC819;
    reg [15:0] colorViolet = 16'h5031;
    reg [15:0] colorBlue = 16'h067E;
    reg [15:0] colorGreen = 16'h07E0;
    reg [15:0] colorYellow = 16'hF6C9;
    reg [15:0] colorRed = 16'hF0C3;
    reg [15:0] colorWhite = 16'hFFFF;
    reg [15:0] colorBlack = 0;
    
    reg [15:0] pausedata [0:6143];       
    initial $readmemh("pausedata.txt", pausedata);
    
    always @ (posedge CLK100MHZ) begin
        ctr21 <= ctr21 + 1;
        ctr6p25m <= ctr6p25m + 1;                        
        clk6p25m <= ctr6p25m == 0 ? ~clk6p25m : clk6p25m;
        ledreg <= btnL && btnR && !pause ? ledpause : ledvolume;
        
        if (!sw[0] && !pause) begin
            case (volume)
            0: ledvolume <= 1;
            1: ledvolume <= 3;
            2: ledvolume <= 7;
            3: ledvolume <= 15;
            4: ledvolume <= 31;
            5: ledvolume <= 63;
            6: ledvolume <= 127;
            7: ledvolume <= 255;
            8: ledvolume <= 511;
            9: ledvolume <= 1023;
            10: ledvolume <= 2047;
            11: ledvolume <= 4095;
            12: ledvolume <= 8191;
            13: ledvolume <= 16383;
            14: ledvolume <= 32767;
            15: ledvolume <= 65535;
            endcase
        end
        
        else if (sw[0] && !pause) begin
            ledvolume <= mic_in;                    
        end
        
        else begin
            ledvolume <= 0;
        end
        
        if (statechange != 15) begin
            statechange <= 15;       
        end
        
        if (dbounceL && barxpos > 0) begin      
            barxpos <= barxpos - 1;
        end 
        
        if (dbounceR && barxpos < 14) begin      
            barxpos <= barxpos + 1;
        end  
        
        if (btnL && btnR && !pause) begin
            pausectr <= pausectr + 1;
            ledpause <= pausectr == 0 ? (ledpause << 1) + 1 : ledpause;
            
            if (ledpause == 65535) begin
                pause <= 1;
                pausectr <= 0;
                ledpause <= 0;
                cursor <= 0;
            end
        end
        
        else begin
            pausectr <= 1;
            ledpause <= 0;
        end 
        
        if (dbounceU && pause == 1 && cursor > 0) begin
            cursor <= cursor - 1;        
        end                              
                                         
        if (dbounceD && pause == 1 && cursor < 2) begin
            cursor <= cursor + 1;        
        end                              
        
        if (dbounceC && pause == 1 && cursor == 0) begin
            pause <= 0;
            cursor <= 0;
        end                               
                                          
        if (dbounceC && pause == 1 && cursor == 1) begin
            reset <= 1;
            pause <= 0;
            cursor <= 0;
        end                               
                                          
        if (dbounceC && pause == 1 && cursor == 2) begin
            pause <= 0;
            statechange <= 0;             
        end   
        
        if (reset || globalreset) begin
            barxpos <= 7;
            reset <= 0;
        end                                                    
    end
    
    always @ (posedge ctr21[4]) begin 
        if (pause) begin
            case (cursor)                                             
                0: begin                                              
                    if (ypoint >= 19 && ypoint <= 25) begin           
                        oled_data <= ~pausedata[ypoint * 96 + xpoint];
                    end                                               
                                                                      
                    else begin                                        
                        oled_data <= pausedata[ypoint * 96 + xpoint]; 
                    end                                               
                end                                                   
                                                                      
                1: begin                                              
                    if (ypoint >= 27 && ypoint <= 33) begin           
                        oled_data <= ~pausedata[ypoint * 96 + xpoint];
                    end                                               
                                                                      
                    else begin                                        
                        oled_data <= pausedata[ypoint * 96 + xpoint]; 
                    end                                               
                end                                                   
                                                                      
                2: begin                                              
                    if (ypoint >= 35 && ypoint <= 41) begin           
                        oled_data <= ~pausedata[ypoint * 96 + xpoint];
                    end                                               
                                                                      
                    else begin                                        
                        oled_data <= pausedata[ypoint * 96 + xpoint]; 
                    end                                               
                end                                                   
            endcase                                                   
        end
     
        else begin
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
    end
    
    always @ (posedge ctr21[14]) begin
        segdisplayctr <= segdisplayctr + 1;
        
        case (segdisplayctr)
            0: begin
                anreg <= pause || !sw[1] ? 15 : 7;
                if (volume <= 5) begin
                    segreg <= charL;
                end
                
                else if (volume >= 11) begin
                    segreg <= charH;  
                end 
                
                else begin
                    segreg <= charM;
                end                  
            end
            
            1: begin            
                anreg <= 15;     
                segreg <= 127;
            end                 
            
            2: begin            
                anreg <= pause ? 15 : 13;     
                if (volume >= 10) begin
                    segreg <= char1;
                end
                
                else begin
                    segreg <= char0;
                end
            end                 
            
            3: begin            
                anreg <= pause ? 15 : 14;
                case (volume)           
                    0: begin            
                        segreg <= char0;
                    end                 
                                        
                    1: begin            
                        segreg <= char1;
                    end                 
                                        
                    2: begin            
                        segreg <= char2;
                    end                 
                                        
                    3: begin            
                        segreg <= char3;
                    end                 
                                        
                    4: begin            
                        segreg <= char4;
                    end                 
                                        
                    5: begin            
                        segreg <= char5;
                    end                 
                                        
                    6: begin            
                        segreg <= char6;
                    end                 
                                        
                    7: begin            
                        segreg <= char7;
                    end                 
                                        
                    8: begin            
                        segreg <= char8;
                    end                 
                                        
                    9: begin            
                        segreg <= char9;
                    end                 
                                        
                    10: begin           
                        segreg <= char0;
                    end                 
                                        
                    11: begin           
                        segreg <= char1;
                    end                 
                                        
                    12: begin           
                        segreg <= char2;
                    end                 
                                        
                    13: begin           
                        segreg <= char3;
                    end                 
                                        
                    14: begin           
                        segreg <= char4;
                    end                 
                                        
                    15: begin           
                        segreg <= char5;
                    end 
                endcase                
            end                 
        endcase
    end
endmodule