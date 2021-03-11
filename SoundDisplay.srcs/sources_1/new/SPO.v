`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2021 12:02:10 AM
// Design Name: 
// Module Name: SPO
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


module SPO(
    input SLOWCLOCK,
    input D,
    output Q
    );
    
    wire Dint;
    wire Qint;
    
    assign Q = Dint & ~Qint;
    
    dFlip flip1(SLOWCLOCK, D, Dint);
    dFlip flip2(SLOWCLOCK, Dint, Qint);
endmodule
