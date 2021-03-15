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
    
    reg [6:0] char0 = 7'b1000000;
    reg [6:0] char1 = 7'b1111001;
    reg [6:0] char2 = 7'b0100100;
    reg [6:0] char3 = 7'b0110000;
    reg [6:0] char4 = 7'b0011001;
    reg [6:0] char5 = 7'b0010010;
    reg [6:0] charDASH = 7'b0111111;
   
    wire convertclk20;
    reg pause = 0;
    reg gameover = 0;
    reg [20:0] pausectr = 0;
    reg [3:0] cursor = 0;
    reg reset = 0;
    reg [1:0] segdisplayctr = 0;
    reg playerBlink = 0;
    reg comBlink = 0;
    
    reg [26:0] ctr27 = 0;
 
    reg [15:0] colorWhite = 16'hFFFF;
    reg [15:0] colorBlack = 0; 
    
    reg [15:0] pausedata [0:6143];       
    initial $readmemh("pausedata.txt", pausedata);
    reg [15:0] gameoverdata [0:6143];       
    initial $readmemh("gameover.txt", gameoverdata);
    
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
    
    SPO twentytoCLK(CLK100MHZ, CLK100MHZ, ctr27[20], convertclk20);
    
    always @ (posedge CLK100MHZ) begin                   
        ctr27 <= ctr27 + 1;
        
        if (statechange != 15) begin
            statechange <= 15;       
        end                         
        
        if (dbounceU && playerPaddlePos <= 11 && !pause && !gameover) begin
            playerPaddlePos <= playerPaddlePos + 1; 
        end                                         
                                                    
        if (dbounceD && playerPaddlePos >= 3 && !pause && !gameover) begin 
            playerPaddlePos <= playerPaddlePos - 1; 
        end  
        
        if (btnL && btnR && !pause) begin                             
            pausectr <= pausectr + 1;                                 
            ledreg <= pausectr == 0 ? (ledreg << 1) + 1 : ledreg;     
                                                                      
            if (ledreg == 65535) begin                                
                pause <= 1;                                           
                pausectr <= 0;                                        
                ledreg <= 0;                                          
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
        
        if (dbounceU && gameover == 1 && cursor > 0) begin
            cursor <= cursor - 1;                      
        end                                            
                                                       
        if (dbounceD && gameover == 1 && cursor < 1) begin
            cursor <= cursor + 1;                      
        end                                                                                                       
                                                                      
        if (dbounceC && pause == 1 && cursor == 0) begin              
            pause <= 0; 
            cursor <= 0;                                              
        end                                                           
                                                                      
        if (dbounceC && pause == 1 && cursor == 1) begin              
            reset <= 1;
            cursor <= 0;                                               
            pause <= 0;
        end                                                         
                                                                      
        if (dbounceC && pause == 1 && cursor == 2) begin              
            statechange <= 0; 
            cursor <= 0; 
            pause <= 0;                                       
        end
        
        if (dbounceC && gameover == 1 && cursor == 0) begin 
            reset <= 1;                                  
            cursor <= 0;                                 
            gameover <= 0;                                  
        end                                              
                                                         
        if (dbounceC && gameover == 1 && cursor == 1) begin 
            statechange <= 0;                            
            cursor <= 0;                                 
            gameover <= 0;                                  
        end
    
        //Begin game logic
        if (convertclk20) begin
            //Ball hits top of screen
            if (ballYpos == 4 && ballYvel == 1) begin
                ballYvel <= ~ballYvel;
            end
            
            //Ball hits bottom of screen
            if (ballYpos == 59 && ballYvel == 0) begin
                ballYvel <= ~ballYvel;                
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
                    if (pause) begin
                        ballXpos <= ballXpos;
                    end
                    
                    else begin
                        ballXpos <= !scoreWait ? ballXpos + 1 : 45;
                    end
                end
                
                1: begin
                    if (pause) begin                               
                        ballXpos <= ballXpos;                      
                    end                                            
                                                                   
                    else begin                                     
                        ballXpos <= !scoreWait ? ballXpos - 1 : 45;
                    end                                                           
                end
            endcase
            
            //Ball Y velocity
            case (ballYvel)                  
                0: begin                     
                    if (pause) begin                               
                        ballYpos <= ballYpos;                      
                    end                                            
                                                                   
                    else begin                                     
                        ballYpos <= !scoreWait ? ballYpos + 1 : 30;
                    end                                           
                end                          
                                             
                1: begin                     
                    if (pause) begin                               
                        ballYpos <= ballYpos;                      
                    end                                            
                                                                   
                    else begin                                     
                        ballYpos <= !scoreWait ? ballYpos - 1 : 30;
                    end                                     
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
                scoreWait <= 1;              
                ballXpos <= 45;                
                ballYpos <= 30;                
            end
            
            //Wait before starting new round
            if (scoreWait == 1) begin
                waitctr <= waitctr + 1;
                
                if (waitctr == 0) begin
                    playerScore <= (playerScore == 5 || comScore == 5) ? 0 : playerScore;
                    comScore <= (playerScore == 5 || comScore == 5) ? 0 : comScore;
                    gameover <= (playerScore == 5 || comScore == 5) ? 1 : gameover;
                    scoreWait <= 0;
                end
                
                if (lastPlayerWin == 1) begin
                    playerBlink <= waitctr[3] == 1 ? 1 : 0;
                end
                
                if (lastPlayerWin == 0) begin
                    comBlink <= waitctr[3] == 1 ? 1 : 0;
                end
            end
            
            //Reset
            if (reset || globalreset) begin 
                playerScore <= 0; 
                comScore <= 0;
                ballXpos <= 45;
                ballYpos <= 30;
                scoreWait <= 1;
                reset <= 0;                                          
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
    
    always @ (posedge ctr27[14]) begin
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
        
        else if (gameover) begin
        case (cursor)
            0: begin                                              
                if (ypoint >= 19 && ypoint <= 25) begin           
                    oled_data <= ~gameoverdata[ypoint * 96 + xpoint];
                end                                               
                                                                  
                else begin                                        
                    oled_data <= gameoverdata[ypoint * 96 + xpoint]; 
                end                                               
            end                                                   
                                                                  
            1: begin                                              
                if (ypoint >= 27 && ypoint <= 33) begin           
                    oled_data <= ~gameoverdata[ypoint * 96 + xpoint];
                end                                               
                                                                  
                else begin                                        
                    oled_data <= gameoverdata[ypoint * 96 + xpoint]; 
                end                                               
            end
        endcase                                                   
        end                                                          
    
        else begin
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
                oled_data <= colorBlack;                                    
            end  
        end                                                  
    end                                                                                                                    
endmodule
