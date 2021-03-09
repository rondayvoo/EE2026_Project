`timescale 1ns / 1ps

module audiolevel (
    //Port JB, bottom row for mic
    input  J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,    // Connect to this signal from Audio_Capture.v
    
    input CLK100MHZ,
    input [15:0] sw,
    //sw[0] toggles peak mode
    //sw[1] shows alphabet on 7seg
    output [15:0] led,
    output [3:0] an,
    output [6:0] seg,
    output reg [3:0] ave
    );
    
    reg [6:0] charL = 7'b1000111;
    reg [6:0] charM = 7'b1101010;
    reg [6:0] charH = 7'b0001001;
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
    
    reg [11:0] SEGCTR = 0;
    reg SEGCLOCK = 0;
    wire [3:0] anreg;
    wire [6:0] segreg;
    reg [6:0] seg1 = 127;
    reg [6:0] seg2 = 127;
    reg [6:0] seg3 = 127;
    reg [6:0] seg4 = 127;
    
    reg [11:0] ctr20k = 0;
    reg clk20k = 0;
    wire [11:0] mic_in;
    reg [15:0] ledave = 0;
    reg [15:0] ledpeak = 0;
    
    Audio_Capture microphone(CLK100MHZ, clk20k, J_MIC3_Pin3, J_MIC3_Pin1, J_MIC3_Pin4, mic_in);
    Sixtyfour_to_One_Average averager(clk20k, mic_in[11:8], ave);
    Complex_Seven display(SEGCLOCK, seg1, seg2, seg3, seg4, anreg, segreg);
    
    assign an = anreg;
    assign seg = segreg;
    assign led = sw[0] ? ledave : mic_in & 16'b0000111111111111;
    
    always @ (posedge CLK100MHZ) begin
        ctr20k <= ctr20k >= 2500 ? 0 : ctr20k + 1;
        clk20k <= ctr20k == 0 ? ~clk20k : clk20k;
        SEGCTR <= SEGCTR + 1;
        SEGCLOCK <= SEGCTR == 0 ? ~SEGCLOCK : SEGCLOCK;
        
        ledave[0] <= ave >= 0 ? 1 : 0;  
        ledave[1] <= ave >= 1 ? 1 : 0;  
        ledave[2] <= ave >= 2 ? 1 : 0;  
        ledave[3] <= ave >= 3 ? 1 : 0;  
        ledave[4] <= ave >= 4 ? 1 : 0;  
        ledave[5] <= ave >= 5 ? 1 : 0;  
        ledave[6] <= ave >= 6 ? 1 : 0;  
        ledave[7] <= ave >= 7 ? 1 : 0;  
        ledave[8] <= ave >= 8 ? 1 : 0;  
        ledave[9] <= ave >= 9 ? 1 : 0;  
        ledave[10] <= ave >= 10 ? 1 : 0;
        ledave[11] <= ave >= 11 ? 1 : 0;
        ledave[12] <= ave >= 12 ? 1 : 0;
        ledave[13] <= ave >= 13 ? 1 : 0;
        ledave[14] <= ave >= 14 ? 1 : 0;
        ledave[15] <= ave >= 15 ? 1 : 0;
        
        ledpeak <= ledpeak | ledave;
    end
    
    always @ (posedge ctr20k) begin
    end
    
    always @ (posedge SEGCLOCK) begin
        case (ave)
            0: begin
                seg1 <= sw[1] ? charL : 127;
                seg3 <= char0;
                seg4 <= char0;
            end
            
            1: begin
                seg1 <= sw[1] ? charL : 127;
                seg3 <= char0;
                seg4 <= char1;
            end
            
            2: begin
                seg1 <= sw[1] ? charL : 127;
                seg3 <= char0;
                seg4 <= char2;
            end 
            
            3: begin
                seg1 <= sw[1] ? charL : 127;
                seg3 <= char0;
                seg4 <= char3;
            end     
            
            4: begin
                seg1 <= sw[1] ? charL : 127;
                seg3 <= char0;
                seg4 <= char4;
            end     
            
            5: begin
                seg1 <= sw[1] ? charL : 127;
                seg3 <= char0;
                seg4 <= char5;
            end     
            
            6: begin
                seg1 <= sw[1] ? charM : 127;
                seg3 <= char0;
                seg4 <= char6;
            end     
            
            7: begin
                seg1 <= sw[1] ? charM : 127;
                seg3 <= char0;
                seg4 <= char7;
            end     
            
            8: begin
                seg1 <= sw[1] ? charM : 127;
                seg3 <= char0;
                seg4 <= char8;
            end     
            
            9: begin
                seg1 <= sw[1] ? charM : 127;
                seg3 <= char0;
                seg4 <= char9;
            end     
            
            10: begin
                seg1 <= sw[1] ? charM : 127;
                seg3 <= char1;
                seg4 <= char0;
            end     
            
            11: begin
                seg1 <= sw[1] ? charH : 127;
                seg3 <= char1;
                seg4 <= char1;
            end     
            
            12: begin
                seg1 <= sw[1] ? charH : 127;
                seg3 <= char1;
                seg4 <= char2;
            end  
            
            13: begin
               seg1 <= sw[1] ? charH : 127;
                seg3 <= char1;
                seg4 <= char3;
            end
            
            14: begin
                seg1 <= sw[1] ? charH : 127;
                seg3 <= char1;
                seg4 <= char4;
            end
            
            15: begin
                seg1 <= sw[1] ? charH : 127;
                seg3 <= char1;
                seg4 <= char5;
            end           
        endcase
    end
endmodule