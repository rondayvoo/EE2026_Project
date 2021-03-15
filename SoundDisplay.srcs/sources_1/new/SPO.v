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
    input CLOCK,
    input SLOWCLOCK,
    input D,
    output Q
    );
    
    wire Dint;
    wire Qint;
    wire Cint;
    wire L;
    
    assign Q = Cint & ~L;
    
    dFlip flip1(SLOWCLOCK, D, Dint);
    dFlip flip2(SLOWCLOCK, Dint, Qint);
    dFlip flip3(CLOCK, Dint & ~Qint, Cint);
    dFlip flip4(CLOCK, Cint, L);
endmodule
