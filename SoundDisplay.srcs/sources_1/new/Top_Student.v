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
    output [3:0] an,
    output [6:0] seg,
    output dp,
    output [15:0] led,
    output [0:7] JDisplay //Port JB for display
    );
    
    reg [20:0] dbouncectr = 0;
    reg [3:0] stateMUX = 4;
    reg globalreset = 0;
    reg [7:0] globalresetctr = 0;
    wire dbounceGR;
    
    wire dbounceC;
    wire dbounceD;
    wire dbounceL;
    wire dbounceR;
    wire dbounceU;
    
    reg [15:0] ledreg = 0;
    reg [3:0] anreg = 127;
    reg [6:0] segreg = 15;
    reg dpreg = 1;
    
    reg [11:0] ctr20k = 0;
    reg clk20k = 0;
    wire [11:0] mic_in;
    
    reg [2:0] ctr6p25m = 0;
    reg clk6p25m = 0;
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [12:0] pixel_index;
    reg [15:0] oled_data = 0;
    wire [4:0] teststate;
    
    //Menu data
    wire [15:0] menu_led_data;
    wire [3:0] menu_an_data;
    wire [6:0] menu_seg_data;
    wire [15:0] menu_oled_data;
    wire [3:0] menu_statechange;
    
    //VBar data
    wire [15:0] bar_led_data; 
    wire [3:0] bar_an_data;   
    wire [6:0] bar_seg_data;  
    wire [15:0] bar_oled_data;
    wire [3:0] bar_statechange;
    
    //Pong data
    wire [15:0] pong_led_data; 
    wire [3:0] pong_an_data;   
    wire [6:0] pong_seg_data;  
    wire [15:0] pong_oled_data;
    wire [3:0] pong_statechange;
    
    //Snake data
    wire [15:0] snake_led_data; 
    wire [3:0] snake_an_data;   
    wire [6:0] snake_seg_data;  
    wire [15:0] snake_oled_data;
    wire [3:0] snake_statechange;
    
    wire [6:0] xpoint;
    wire [5:0] ypoint;
    
    assign led = ledreg;
    assign an = anreg;
    assign seg = segreg;
    assign dp = 1;
    
    SPO dbC(CLK100MHZ, dbouncectr[20], btnC, dbounceC);
    SPO dbD(CLK100MHZ, dbouncectr[20], btnD, dbounceD);
    SPO dbL(CLK100MHZ, dbouncectr[20], btnL, dbounceL);
    SPO dbR(CLK100MHZ, dbouncectr[20], btnR, dbounceR);
    SPO dbU(CLK100MHZ, dbouncectr[20], btnU, dbounceU);
    SPO dbRESET(CLK100MHZ, CLK100MHZ, globalreset, dbounceGR);
    Coordinate_Converter c0(pixel_index, xpoint, ypoint);
    
    mainmenu menu(CLK100MHZ, btnC, btnD, btnL, btnR, btnU, 
                  dbounceC, dbounceD, dbounceL, dbounceR, dbounceU, xpoint, ypoint, dbounceGR,
                  menu_led_data, menu_an_data, menu_seg_data, menu_oled_data, menu_statechange);
    volumebar bar(CLK100MHZ, sw, btnC, btnD, btnL, btnR, btnU, 
                  dbounceC, dbounceD, dbounceL, dbounceR, dbounceU, xpoint, ypoint, dbounceGR,
                  bar_led_data, bar_an_data, bar_seg_data, bar_oled_data, bar_statechange);
    voicepong pong(CLK100MHZ, btnC, btnD, btnL, btnR, btnU,  
                   dbounceC, dbounceD, dbounceL, dbounceR, dbounceU, xpoint, ypoint, dbounceGR,
                   pong_led_data, pong_an_data, pong_seg_data, pong_oled_data, pong_statechange);
    solidsnake snake(CLK100MHZ, btnC, btnD, btnL, btnR, btnU,  
                     dbounceC, dbounceD, dbounceL, dbounceR, dbounceU, xpoint, ypoint, dbounceGR,
                     snake_led_data, snake_an_data, snake_seg_data, snake_oled_data, snake_statechange);
    
    //Audio_Capture microphone(CLK100MHZ, clk20k, J_MIC3_Pin3, J_MIC3_Pin1, J_MIC3_Pin4, mic_in);
    Oled_Display d0(clk6p25m, 0, frame_begin, sending_pixels, sample_pixel, pixel_index, oled_data,
                         JDisplay[0], JDisplay[1], JDisplay[3], JDisplay[4], JDisplay[5], JDisplay[6], JDisplay[7], teststate);
    
    //assign led[11:0] = sw[0] ? mic_in : 0;
    
    always @ (posedge CLK100MHZ) begin
        ctr20k <= ctr20k == 2500 ? 0 : ctr20k + 1;
        clk20k <= ctr20k == 0 ? ~clk20k : clk20k;
        ctr6p25m <= ctr6p25m + 1;
        clk6p25m <= ctr6p25m == 0 ? ~clk6p25m : clk6p25m;
        dbouncectr <= dbouncectr + 1;
        
        if (globalreset) begin
            globalreset <= 0;
        end
        
        case (stateMUX)
            0: begin //Main menu
                //menuclk = CLK100MHZ;
                ledreg <= menu_led_data; 
                oled_data <= menu_oled_data;
                anreg <= menu_an_data;
                segreg <= menu_seg_data;
                
                if (menu_statechange != 15) begin
                    globalreset <= 1;
                    stateMUX <= menu_statechange;
                end
            end
            
            1: begin //Volume bars                   
                //barclk = CLK100MHZ;
                ledreg <= bar_led_data;        
                oled_data <= bar_oled_data;
                anreg <= bar_an_data;
                segreg <= bar_seg_data;
                
                if (bar_statechange != 15) begin
                    globalreset <= 1;            
                    stateMUX <= bar_statechange;
                end                              
            end   
            
            2: begin //Waveform
            end                          
            
            3: begin //Pong      
                ledreg <= pong_led_data;       
                oled_data <= pong_oled_data;
                anreg <= pong_an_data;
                segreg <= pong_seg_data;
                
                if (pong_statechange != 15) begin
                    globalreset <= 1;
                    stateMUX <= pong_statechange;
                end
            end
            
            4: begin //Snake
                ledreg <= snake_led_data;         
                oled_data <= snake_oled_data;     
                anreg <= snake_an_data;           
                segreg <= snake_seg_data;         
                                                 
                if (snake_statechange != 15) begin
                    globalreset <= 1;            
                    stateMUX <= snake_statechange;
                end 
            end              
        endcase
        
        //oled_data[4:0] <= mic_in[11:8]; //Red
        //oled_data[10:5] <= mic_in[11:7]; //Green
        //oled_data[15:11] <= mic_in[11:8]; //Blue
    end

endmodule