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
    reg [12:0] rng = 6311;
    reg [12:0] score = 0;
    
    reg [15:0] colorWhite = 16'hFFFF;
    reg [15:0] colorBlack = 0; 
    reg [15:0] colorRed = 16'hF0C3; 
    reg [15:0] colorBlue = 16'h067E;
    
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
    
    reg [15:0] pausedata [0:6143];       
    initial $readmemh("pausedata.txt", pausedata);
    reg [15:0] gameoverdata [0:6143];       
    initial $readmemh("gameover.txt", gameoverdata); 
    
    reg [6:0] headxpos = 12;
    reg [5:0] headypos = 4;
    reg [6:0] tailxpos = 4;
    reg [5:0] tailypos = 4;
    reg [6:0] pelletxpos = 10;
    reg [5:0] pelletypos = 10;
    reg eaten = 0;
    reg newpellet = 0;
    
    reg [1:0] lastdir = 0; 
    //0: Right
    //1: Down
    //2: Left
    //3: Up
    reg [14:0] length = 8;
    reg [1535:0] snakemap = 0;
    reg [2759:0] commandline = 0;
    
    SPO twentytwotoCLK(CLK100MHZ, CLK100MHZ, ctr27[22], convertclk22);
    
    always @ (posedge CLK100MHZ) begin                   
        ctr27 <= ctr27 + 1;
        rng <= rng == 6311 ? 0 : rng + 911;
        
        //Reset                        
        if (reset || globalreset) begin       
            headxpos <= 11;
            headypos <= 4;
            tailxpos <= 4;
            tailypos <= 4;
            length <= 8;
            pelletxpos <= 10;
            pelletypos <= 10;
            lastdir <= 0;
            snakemap <= 0;
            commandline <= 0;
            score <= 0;
            eaten <= 0;
            newpellet <= 0;          
            reset <= 0;                
        end     
        
        if (statechange != 15) begin
            statechange <= 15;       
        end                        
        
        if (dbounceR && pause != 1 && gameover != 1 && lastdir != 2) begin
            lastdir <= 0;
        end
        
        else if (dbounceD && pause != 1 && gameover != 1 && lastdir != 3) begin
            lastdir <= 1;                             
        end                                               
        
        else if (dbounceL && pause != 1 && gameover != 1 && lastdir != 0) begin
            lastdir <= 2;                             
        end                                               
        
        else if (dbounceU && pause != 1 && gameover != 1 && lastdir != 1) begin
            lastdir <= 3;                              
        end
        
        if (eaten) begin
            case (commandline[(length - 1) * 2 + 1])                     
            0: begin                                                 
                case (commandline[(length - 1) * 2])                 
                    0: tailxpos <= tailxpos == 45 ? 2 : tailxpos - 1;
                    1: tailypos <= tailypos == 29 ? 2 : tailypos - 1;
                endcase                                              
            end                                                      
                                                                     
            1: begin                                                 
                case (commandline[(length - 1) * 2])                 
                    0: tailxpos <= tailxpos == 2 ? 45 : tailxpos + 1;
                    1: tailypos <= tailypos == 2 ? 29 : tailypos + 1;
                endcase                                              
            end                                                      
            endcase 
                                                                 
            length <= length + 1;
            score <= score + 1;
            eaten <= 0;
        end
        
        if (newpellet) begin
            if (rng % 48 > 2 && rng % 48 < 46 &&
                rng / 48 > 2 && rng / 48 < 30 &&
                !snakemap[rng]) begin
                pelletxpos <= rng % 48;
                pelletypos <= rng / 48;
                newpellet <= 0;
            end
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
        
        if (convertclk22 && !pause && !gameover) begin
            commandline <= (commandline << 2) + lastdir;
        
            case (lastdir) 
                0: begin
                    headxpos <= headxpos == 45 ? 2: headxpos + 1;
                    commandline <= (commandline << 2) + 0;
                end
                
                1: begin
                    headypos <= headypos == 29 ? 2 : headypos + 1;
                    commandline <= (commandline << 2) + 1; 
                end
                
                2: begin 
                    headxpos <= headxpos == 2 ? 45 : headxpos - 1;
                    commandline <= (commandline << 2) + 2;
                end
                
                3: begin 
                    headypos <= headypos == 2 ? 29 : headypos - 1;
                    commandline <= (commandline << 2) + 3;
                end
            endcase
            
            case (commandline[(length - 2) * 2 + 1])
                0: begin 
                    case (commandline[(length - 2) * 2])
                        0: tailxpos <= tailxpos == 45 ? 2 : tailxpos + 1;
                        1: tailypos <= tailypos == 29 ? 2 : tailypos + 1;
                    endcase
                end
                
                1: begin
                    case (commandline[(length - 2) * 2])
                        0: tailxpos <= tailxpos == 2 ? 45 : tailxpos - 1;    
                        1: tailypos <= tailypos == 2 ? 29 : tailypos - 1;    
                    endcase                             
                end
            endcase
            
            snakemap[48 * headypos + headxpos] <= 1;
            snakemap[48 * tailypos + tailxpos] <= 0;  
            
            if (headxpos == pelletxpos && headypos == pelletypos) begin                               
                eaten <= 1;
                newpellet <= 1;
            end
            
            
            if ((snakemap[headxpos + 1] && lastdir == 0) ||
                (snakemap[headypos + 1] && lastdir == 1) ||
                (snakemap[headxpos - 1] && lastdir == 2) ||
                (snakemap[headypos - 1] && lastdir == 3)) begin
                gameover <= 1;
            end
            
        end
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
        
            if (snakemap[48 * (ypoint / 2) + xpoint / 2]) begin
                oled_data <= colorBlue;
            end
            
            
            /*
            if (xpoint >= headxpos && xpoint <= headxpos + 1 &&
                ypoint >= headypos && ypoint <= headypos + 1) begin
                    oled_data <= colorBlue;
            end
            
            else if (xpoint >= tailxpos && xpoint <= tailxpos + 1 &&
                     ypoint >= tailypos && ypoint <= tailypos + 1) begin
                    oled_data <= colorBlue;
            end
            */
            
            else if (xpoint >= pelletxpos * 2 && xpoint <= pelletxpos * 2 + 1 &&
                     ypoint >= pelletypos * 2 && ypoint <= pelletypos * 2 + 1) begin
                oled_data <= colorRed;
            end
            
            else if (!(xpoint >= 4 && xpoint <= 91 &&              
                ypoint >= 4 && ypoint <= 59)) begin
                oled_data <= colorWhite;
            end
            
            else begin
                oled_data <= colorBlack;
            end
        end
    end
    
    always @ (posedge ctr27[14]) begin                         
        //Score display                                        
        segdisplayctr <= segdisplayctr + 1;                    
                                                               
        case (segdisplayctr)                                   
            0: begin                                           
                anreg <= 15;                                                   
            end                                                
                                                               
            1: begin                                           
                anreg <= 11; 
                case (score / 100 % 10)   
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
                endcase                                            
            end                                                
                                                               
            2: begin                                           
                anreg <= 13; 
                case (score / 10 % 10)
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
                endcase                                           
            end                                                
                                                               
            3: begin                                           
                anreg <= 14;              
                case (score % 10)                                
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
                endcase                                        
            end                                                
        endcase                                                
    end                                                        
endmodule