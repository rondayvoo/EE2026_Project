`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2021 09:19:02 PM
// Design Name: 
// Module Name: Coordinate_Converter
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


module Coordinate_Converter(
    input [6:0] xpos,
    input [5:0] ypos,
    output [12:0] pxindex
    );
    
    assign pxindex = ypos * 96 + xpos;
endmodule
