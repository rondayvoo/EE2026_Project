`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2021 10:34:55 PM
// Design Name: 
// Module Name: voicepong
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


module voicepong (                                                  
    input CLK100MHZ, 
    output [6:0] seg,
    output [3:0] an,
    output dp,                               
    input btnC,                                                       
    input btnD,                                                       
    input btnL,                                                       
    input btnR,                                                       
    input btnU,                                                      
    output [0:7] JDisplay //Port JB for display                       
    );  
    
    reg [6:0] char0 = 7'b1000000;
    reg [6:0] char1 = 7'b1111001;
    reg [6:0] char2 = 7'b0100100;
    reg [6:0] char3 = 7'b0110000;
    reg [6:0] char4 = 7'b0011001;
    reg [6:0] char5 = 7'b0010010;
    reg [6:0] charDASH = 7'b0111111;
    
    reg [6:0] segreg = 127;
    reg [3:0] anreg = 15;
    reg [1:0] segdisplayctr = 0;
    reg playerBlink = 0;
    reg comBlink = 0;
    
    reg [26:0] ctr27 = 0;
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
    
    reg [15:0] colorWhite = 16'hFFFF;
    reg [15:0] colorBlack = 0; 
    
    reg [3:0] playerPaddlePos = 7;
    reg [3:0] comPaddlePos = 7;
    reg [6:0] ballXpos = 45;
    reg [5:0] ballYpos = 30;
    reg ballXvel = 0;
    reg ballYvel = 0;
    reg [2:0] playerScore = 0;
    reg [2:0] comScore = 0;
    reg scoreWait = 1;
    reg [5:0] waitctr = 0;
    reg lastPlayerWin = 0;
    
    assign seg = segreg;
    assign an = anreg;
    assign dp = 1;
    
    SPO dbC(ctr27[20], btnC, dbounceC);                                                                                   
    SPO dbD(ctr27[20], btnD, dbounceD);                                                                                   
    SPO dbL(ctr27[20], btnL, dbounceL);                                                                                   
    SPO dbR(ctr27[20], btnR, dbounceR);                                                                                   
    SPO dbU(ctr27[20], btnU, dbounceU);                                                                                   
                                                                                                                          
    Oled_Display d0(clk6p25m, dbounceC, frame_begin, sending_pixels, sample_pixel, pixel_index, oled_data,                
                    JDisplay[0], JDisplay[1], JDisplay[3], JDisplay[4], JDisplay[5], JDisplay[6], JDisplay[7], teststate);
    Coordinate_Converter p0(pixel_index, xpoint, ypoint);  
    
    always @ (posedge CLK100MHZ) begin                   
        ctr27 <= ctr27 + 1;                              
        ctr6p25m <= ctr6p25m + 1;                        
        clk6p25m <= ctr6p25m == 0 ? ~clk6p25m : clk6p25m;
    end    
    
    always @ (posedge ctr27[20]) begin
        //Button inputs
        if (dbounceU && playerPaddlePos <= 11) begin
            playerPaddlePos <= playerPaddlePos + 1;
        end
        
        if (dbounceD && playerPaddlePos >= 3) begin
            playerPaddlePos <= playerPaddlePos - 1;
        end
        
        //Ball hits top of screen
        if (ballYpos == 4 && ballYvel == 1) begin
            ballYvel = ~ballYvel;
        end
        
        //Ball hits bottom of screen
        if (ballYpos == 59 && ballYvel == 0) begin
            ballYvel = ~ballYvel;                
        end 
        
        //Ball gets hit by player
        if (ballXpos == 10 && ballXvel == 1 && 
            ballYpos >= 24 - (playerPaddlePos - 7) * 4 && ballYpos <= 38 - (playerPaddlePos - 7) * 4) begin
            ballXvel <= ~ballXvel;
        end
        
        //Ball gets hit by computer                
        if (ballXpos == 84 && ballXvel == 0 &&
            ballYpos >= 24 - (comPaddlePos - 7) * 4 && ballYpos <= 38 - (comPaddlePos - 7) * 4) begin
            ballXvel <= ~ballXvel;                
        end 
        
        //Ball X velocity                                                                          
        case (ballXvel)
            0: begin
                ballXpos <= scoreWait == 0 ? ballXpos + 1 : 45;
            end
            
            1: begin
                ballXpos <= scoreWait == 0 ? ballXpos - 1 : 45;
            end
        endcase
        
        //Ball Y velocity
        case (ballYvel)                  
            0: begin                     
                ballYpos <= scoreWait == 0 ? ballYpos + 1 : 30;
            end                          
                                         
            1: begin                     
                ballYpos <= scoreWait == 0 ? ballYpos - 1 : 30;
            end                          
        endcase
        
        //COM scores
        if (ballXpos == 4) begin
            comScore <= comScore + 1;
            lastPlayerWin <= 0;
            scoreWait <= 1;
            ballXvel <= ~ballXvel; 
            ballXpos <= 45;
            ballYpos <= 30;
        end
        
        //Player scores
        if (ballXpos == 90) begin           
            playerScore <= playerScore + 1;
            lastPlayerWin <= 1;
            scoreWait <= 1; 
            ballXvel <= ~ballXvel;               
            ballXpos <= 45;                
            ballYpos <= 30;                
        end
        
        if (scoreWait == 1) begin
            waitctr <= waitctr + 1;
            
            if (waitctr == 0) begin
                playerScore <= (playerScore == 5 || comScore == 5) ? 0 : playerScore;
                comScore <= (playerScore == 5 || comScore == 5) ? 0 : comScore;
                scoreWait <= 0;
            end
            
            if (lastPlayerWin == 1) begin
                playerBlink <= waitctr[3] == 1 ? 1 : 0;
            end
            
            if (lastPlayerWin == 0) begin
                comBlink <= waitctr[3] == 1 ? 1 : 0;
            end
        end
    end
    
    always @ (posedge ctr27[22]) begin
        //COM AI
        if (ballYpos < 25 - (comPaddlePos - 7) * 4 && comPaddlePos <= 11) begin
            comPaddlePos <= comPaddlePos + 1;
        end
        
        else if (ballYpos > 37 - (comPaddlePos - 7) * 4 && comPaddlePos >= 3) begin
            comPaddlePos <= comPaddlePos - 1;
        end
    end
    
    always @ (posedge ctr27[13]) begin
        //Score display
        segdisplayctr <= segdisplayctr + 1;
        
        case (segdisplayctr)
            0: begin
                anreg <= playerBlink == 0 ? 7 : 15;
                case (playerScore)
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
                endcase
            end
            
            1: begin
                anreg <= 11;
                segreg <= charDASH;
            end
            
            2: begin
                anreg <= 13;
                segreg <= charDASH;
            end
            
            3: begin
                anreg <= comBlink == 0 ? 14 : 15;
                case (comScore)     
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
                endcase
            end
        endcase
    end
    
    always @ (posedge clk6p25m) begin
        //Paddles
        if (xpoint >= 8 && xpoint <= 9 &&    
            ypoint >= 25 - (playerPaddlePos - 7) * 4 && ypoint <= 37 - (playerPaddlePos - 7) * 4) begin
            oled_data <= colorWhite;           
        end 
        
        else if (xpoint >= 86 && xpoint <= 87 &&     
            ypoint >= 25 - (comPaddlePos - 7) * 4 && ypoint <= 37 - (comPaddlePos - 7) * 4) begin
            oled_data <= colorWhite;           
        end                                     
                                          
        //Ball
        else if (xpoint >= ballXpos && xpoint <= ballXpos + 1 &&              
            ypoint >= ballYpos && ypoint <= ballYpos + 1) begin
            oled_data <= colorWhite;
        end
        
        //Screen border                                                       
        else if (!(xpoint >= 4 && xpoint <= 91 &&              
                 ypoint >= 4 && ypoint <= 59)) begin 
            oled_data <= colorWhite;                           
        end                                                    
                                                               
        else begin                                             
            oled_data <= 0;                                    
        end                                                    
    end                                                                                                                    
endmodule
