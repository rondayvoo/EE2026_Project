`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2021 03:58:32 PM
// Design Name: 
// Module Name: Sixtyfour_to_One_Average
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


module Sixtyfour_to_One_Average(
    input SAMPLECLOCK,
    input [3:0] data,
    output reg [3:0] average
    );
    
    reg [3:0] ctr = 0;
    reg [9:0] total = 0;
    
    always @ (posedge SAMPLECLOCK) begin
        ctr <= ctr + 1;
        total <= ctr == 0 ? 0 : total + data;
        average <= ctr == 0 ? total[9:6] : average;
    end
endmodule
