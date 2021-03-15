`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2021 09:30:06 PM
// Design Name: 
// Module Name: solidsnake
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


module solidsnake(
    input CLK100MHZ,                 
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
    output reg [3:0] anreg = 127,    
    output reg [6:0] segreg = 15,    
    output reg [15:0] oled_data = 0, 
    output reg [3:0] statechange = 15
    );
    
    wire convertclk22;          
    reg pause = 0;              
    reg gameover = 0;           
    reg [20:0] pausectr = 0;    
    reg [3:0] cursor = 0;       
    reg reset = 0;             
    reg [1:0] segdisplayctr = 0;  
    
    reg [26:0] ctr27 = 0;
    
    reg [15:0] colorWhite = 16'hFFFF;
    reg [15:0] colorBlack = 0; 
    reg [15:0] colorRed = 0; 
    reg [15:0] colorBlue = 16'h067E;
    
    reg [15:0] pausedata [0:6143];       
    initial $readmemh("pausedata.txt", pausedata);
    reg [15:0] gameoverdata [0:6143];       
    initial $readmemh("gameover.txt", gameoverdata); 
    
    integer i;
    integer xindex;
    integer yindex;
    
    reg [6:0] xpos = 8;
    reg [5:0] ypos = 8;
    reg [6143:0] snakemap = 0;
    reg [1:0] lastdir = 0;
    reg [14:0] length = 2;
    reg [2759:0] commandline = 0;
    
    SPO twentytwotoCLK(CLK100MHZ, CLK100MHZ, ctr27[22], convertclk22);
    
    always @ (posedge CLK100MHZ) begin                   
        ctr27 <= ctr27 + 1;
        
        if (dbounceR && pause != 1 && gameover != 1 && lastdir != 2) begin
            commandline <= commandline << 2 + 0;
            lastdir <= 0;
        end
        
        else if (dbounceD && pause != 1 && gameover != 1 && lastdir != 3) begin
            commandline <= commandline << 2 + 1; 
            lastdir <= 1;                             
        end                                               
        
        else if (dbounceL && pause != 1 && gameover != 1 && lastdir != 0) begin
            commandline <= commandline << 2 + 2; 
            lastdir <= 2;                             
        end                                               
        
        else if (dbounceU && pause != 1 && gameover != 1 && lastdir != 1) begin
            commandline <= commandline << 2 + 3;
            lastdir <= 3;                              
        end                                         
        
        if (convertclk22) begin
            commandline <= commandline << 2 + lastdir; 
        
            case (lastdir) 
                0: xpos <= xpos + 2;
                1: ypos <= ypos + 2;
                2: xpos <= xpos - 2;
                3: ypos <= ypos - 2;
            endcase
            
            snakemap <= snakemap | (ypos * 96 + xpos) | (ypos * 96 + xpos + 1) | 
                        ((ypos + 1) * 96 + xpos) | ((ypos + 1) * 96 + xpos + 1);
        end
    end
    
    always @ (posedge ctr27[4]) begin
        if (pause) begin
        end
        
        else if (gameover) begin
        end
        
        else begin
            /*for (i = 0; i < length; i = i + 2) begin
                xindex = commandline[i + 1] == 1 ? xpos + 2 : xpos - 2;
                yindex = commandline[i] == 1 ? ypos + 2 : ypos - 2;
                
                if (i < length - 1) begin
                    snakemap = snakemap + (yindex * 96 + xindex) + (yindex * 96 + xindex + 1) + 
                               ((yindex + 1) * 96 + xindex) + ((yindex + 1) * 96 + xindex + 1);
                end
                
                else begin
                    snakemap = snakemap - (yindex * 96 + xindex) - (yindex * 96 + xindex + 1) - 
                               ((yindex + 1) * 96 + xindex) - ((yindex + 1) * 96 + xindex + 1);
                end
            end*/
            
            if (snakemap[ypoint * 96 + xpoint] == 1) begin
                oled_data <= colorBlue;
            end
            
            /*if (xpoint >= xpos && xpoint <= xpos + 1 &&
                ypoint >= ypos && ypoint <= ypos + 1) begin
                oled_data <= colorBlue;
            end*/
            
            else if (!(xpoint >= 4 && xpoint <= 91 &&              
                ypoint >= 4 && ypoint <= 59)) begin
                oled_data <= colorWhite;
            end
            
            else begin
                oled_data <= colorBlack;
            end
        end
    end
endmodule
