`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2021 11:59:25 PM
// Design Name: 
// Module Name: dFlip
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


module dFlip(
    input CLOCK,
    input D,
    output reg Q
    );
    
    always @ (posedge CLOCK) begin
        Q <= D;
    end
endmodule
