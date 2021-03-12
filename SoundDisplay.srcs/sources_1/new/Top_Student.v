`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//
//  LAB SESSION DAY (Delete where applicable): THURSDAY A.M.
//
//  STUDENT A NAME: Darren Khoo
//  STUDENT A MATRICULATION NUMBER: A0217480H 
//
//  STUDENT B NAME: 
//  STUDENT B MATRICULATION NUMBER: 
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
    //Port JA, top row for mic
    input  J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,    // Connect to this signal from Audio_Capture.v
    
    input CLK100MHZ,
    input [15:0] sw,
    input btnC,
    input btnD,
    input btnL,
    input btnR,
    input btnU,
    output [15:0] led,
    output [0:7] JDisplay //Port JB for display
    );
    
    reg [20:0] dbouncectr = 0;
    
    reg [11:0] ctr20k = 0;
    reg clk20k = 0;
    wire [11:0] mic_in;
    
    reg [2:0] ctr6p25m = 0;
    reg clk6p25m = 0;
    wire reset; //From btnC
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [12:0] pixel_index;
    //reg [15:0] oled_data = 16'h07E0;
    reg [15:0] oled_data = 0;
    
    Audio_Capture microphone(CLK100MHZ, clk20k, J_MIC3_Pin3, J_MIC3_Pin1, J_MIC3_Pin4, mic_in);
    Oled_Display display(clk6p25m, reset, frame_begin, sending_pixels, sample_pixel, pixel_index, oled_data,
                         JDisplay[0], JDisplay[1], JDisplay[3], JDisplay[4], JDisplay[5], JDisplay[6], JDisplay[7]);
    
    SPO dbounceC(dbouncectr[20], btnC, reset);
    
    assign led[11:0] = sw[0] ? mic_in : 0;
    
    always @ (posedge CLK100MHZ) begin
        ctr20k <= ctr20k == 2500 ? 0 : ctr20k + 1;
        clk20k <= ctr20k == 0 ? ~clk20k : clk20k;
        ctr6p25m <= ctr6p25m + 1;
        clk6p25m <= ctr6p25m == 0 ? ~clk6p25m : clk6p25m;
        dbouncectr <= dbouncectr + 1;
        
        oled_data[4:0] <= mic_in[11:8]; //Red
        //oled_data[10:5] <= mic_in[11:7]; //Green
        //oled_data[15:11] <= mic_in[11:8]; //Blue
    end

endmodule