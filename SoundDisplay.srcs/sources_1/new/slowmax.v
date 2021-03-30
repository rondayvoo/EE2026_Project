`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2021 12:10:39 AM
// Design Name: 
// Module Name: slowmax
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


module slowmax(
    input CLK100MHZ,
    input clk20k,
    input [11:0] mic_in,
    output reg [3:0] level
    );
    
    reg [23:0] COUNT24 = 0;
    reg [11:0] max = 0;
    reg [11:0] final = 0;
    
    always @ (posedge CLK100MHZ) begin
        if (max > (2**11)) begin level <= 0; end              
        if (max > (2**11 + 2**7)) begin level <= 1; end       
        if (max > (2**11 + (2**7)*2)) begin level <= 2; end   
        if (max > (2**11 + (2**7)*3)) begin level <= 3; end   
        if (max > (2**11 + (2**7)*4)) begin level <= 4; end   
        if (max > (2**11 + (2**7)*5)) begin level <= 5; end   
        if (max > (2**11 + (2**7)*6)) begin level <= 6; end   
        if (max > (2**11 + (2**7)*7)) begin level <= 7; end   
        if (max > (2**11 + (2**7)*8)) begin level <= 8; end   
        if (max > (2**11 + (2**7)*9)) begin level <= 9; end   
        if (max > (2**11 + (2**7)*10)) begin level <= 10; end 
        if (max > (2**11 + (2**7)*11)) begin level <= 11; end 
        if (max > (2**11 + (2**7)*12)) begin level <= 12; end 
        if (max > (2**11 + (2**7)*13)) begin level <= 13; end 
        if (max > (2**11 + (2**7)*14)) begin level <= 14; end 
        if (max > (2**11 + (2**7)*15)) begin level <= 15; end 
    end
    
    always @ (posedge clk20k) begin                              
        COUNT24 <= (COUNT24 == 2000) ? 0 : COUNT24 + 1;
          
        if (COUNT24 == 0) begin
            max <= 0;
        end   
               
        else begin
            max <= (mic_in > max) ? mic_in : max;
        end  
        
        final <= (COUNT24 == 0) ? max : final;                    
    end                                                          
endmodule
