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
    input [12:0] pxindex,
    output [6:0] xpos,
    output [5:0] ypos
    );
    
    assign xpos = pxindex % 96;
    assign ypos = pxindex / 96;
endmodule
