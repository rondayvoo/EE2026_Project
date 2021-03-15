`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2021 05:38:25 PM
// Design Name: 
// Module Name: mainmenu
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
/////////////////////////////////////////////////////////////////////////////////

module mainmenu(
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
    output reg [3:0] anreg = 15,
    output reg [6:0] segreg = 127,
    output reg [15:0] oled_data = 0,
    output reg [3:0] statechange = 15
    );
    
    reg [3:0] inputwait = 0;
    reg [26:0] ctr27 = 0;
    reg [3:0] cursor = 0;
    reg [15:0] colorWhite = 16'hFFFF;
    reg [15:0] colorBlack = 0;
    reg [15:0] menudata [0:6143];       
    initial $readmemh("menudata.txt", menudata);
    
    always @ (posedge CLK100MHZ) begin
        ctr27 <= ctr27 + 1;
        
        if (statechange != 15) begin
            statechange <= 15;
        end
        
        if (dbounceU && cursor > 0) begin
            cursor <= cursor - 1;
        end
        
        if (dbounceD && cursor < 3) begin
            cursor <= cursor + 1;
        end
        
        if (dbounceC && cursor == 0) begin
            statechange <= 1;
        end
        
        if (dbounceC && cursor == 2) begin
            statechange <= 3;             
        end       
        
        if (globalreset) begin
            cursor <= 0;
            inputwait <= 0;
        end                       
    end
    
    always @ (posedge ctr27[4]) begin
        case (cursor) 
            0: begin
                if (ypoint >= 19 && ypoint <= 25) begin
                    oled_data <= ~menudata[ypoint * 96 + xpoint];
                end
                
                else begin
                    oled_data <= menudata[ypoint * 96 + xpoint];
                end
            end
            
            1: begin
                if (ypoint >= 27 && ypoint <= 33) begin
                    oled_data <= ~menudata[ypoint * 96 + xpoint];
                end
                
                else begin                                      
                    oled_data <= menudata[ypoint * 96 + xpoint];
                end                                             
            end
            
            2: begin                                   
                if (ypoint >= 35 && ypoint <= 41) begin
                    oled_data <= ~menudata[ypoint * 96 + xpoint];           
                end   
                
                else begin                                      
                    oled_data <= menudata[ypoint * 96 + xpoint];
                end                                                                              
            end                                        
            
            3: begin                                   
                if (ypoint >= 43 && ypoint <= 49) begin
                    oled_data <= ~menudata[ypoint * 96 + xpoint];           
                end    
                
                else begin                                      
                    oled_data <= menudata[ypoint * 96 + xpoint];
                end                                                                             
            end                                        
        endcase
    end
endmodule
