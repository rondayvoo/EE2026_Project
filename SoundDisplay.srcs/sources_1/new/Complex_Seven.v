`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2021 04:16:31 PM
// Design Name: 
// Module Name: Complex_Seven
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


module Complex_Seven(
    input FRAMECLOCK,
    input [6:0] seg1,
    input [6:0] seg2,
    input [6:0] seg3,
    input [6:0] seg4,
    output reg [3:0] anout,
    output reg [6:0] segout
    );
    
    reg [1:0] ctr = 0;
    reg [3:0] anreg = 15;
    reg [6:0] segreg = 127;
    
    always @ (posedge FRAMECLOCK) begin
        ctr <= ctr + 1;
        
        case (ctr)
            0: begin
                anreg <= 7;
                segreg <= seg1;
            end
            
            1: begin
                anreg <= 11;
                segreg <= seg2;
            end     
            
            2: begin
                anreg <= 13;
                segreg <= seg3;
            end     
            
            3: begin
                anreg <= 14;
                segreg <= seg4;
            end     
        endcase
    end
endmodule
