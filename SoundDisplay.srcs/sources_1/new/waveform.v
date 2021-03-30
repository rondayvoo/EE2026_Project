`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2021 06:45:33 PM
// Design Name: 
// Module Name: waveform
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module waveform(
    input CLK100MHZ,                  
    input [11:0] mic_in,               
    input [15:0] sw, 
    //sw[0] changes colorscheme
    //sw[1] adds gridlines       
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
    );
    
    reg [26:0] ctr27 = 0;
    reg [15:0] pausedata [0:6143];       
    initial $readmemh("pausedata.txt", pausedata);
    
    reg [484:0] volarray = 0;
    
    reg pause = 0;
    reg [20:0] pausectr = 1;
    reg [3:0] cursor = 0;
    
    reg [15:0] colorGreen = 16'h1FE7;
    reg [15:0] colorRed = 16'h7000;
    reg [15:0] colorBlack = 0;
    reg [15:0] colorWhite = 16'hFFFF;
    
    always @ (posedge CLK100MHZ) begin
        ctr27 <= ctr27 + 1;
        
        if (statechange != 15) begin
            statechange <= 15;       
        end
        
        if (btnL && btnR && !pause) begin                          
            pausectr <= pausectr + 1;                              
            ledreg <= pausectr == 0 ? (ledreg << 1) + 1 : ledreg;  
                                                                   
            if (ledreg == 65535) begin                             
                pause <= 1;                                        
                pausectr <= 0;                                     
                ledreg <= 0; 
                cursor <= 0;                                      
            end                                                    
                                                                   
        end                                                        
                                                                   
        else begin                                                 
            pausectr <= 1;                                         
            ledreg <= 0;                                           
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
            pause <= 0;                                            
            cursor <= 0;                                           
        end                                                        
                                                                   
        if (dbounceC && pause == 1 && cursor == 2) begin           
            pause <= 0;                                            
            statechange <= 0;                                      
        end                                                        
    end
    
    always @ (posedge ctr27[15]) begin
        volarray <= volarray + mic_in[11:7] << 5;
    end
    
    always @ (posedge ctr27[4]) begin
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
            if (ypoint == volarray[5 * (xpoint + 1) + 4] * 16 + volarray[5 * (xpoint  + 1) + 3] * 8 
                + volarray[5 * (xpoint  + 1) + 2] * 4 + volarray[5 * (xpoint  + 1) + 1] * 2 + 
                volarray[5 * (xpoint  + 1)] + 15) begin
                oled_data <= sw[0] ? colorWhite : colorGreen;
            end
            
            else if ((ypoint == 15 || ypoint == 47 ||
                     xpoint == 15 || xpoint == 31 || xpoint == 47 || 
                     xpoint == 63 || xpoint == 79) && sw[1]) begin
                oled_data <= sw[0] ? colorWhite : colorGreen;
            end
            
            else begin
                oled_data <= sw[0] ? colorRed : colorBlack;
            end
        end
    end
endmodule
