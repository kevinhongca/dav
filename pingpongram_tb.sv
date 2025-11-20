

`timescale 1ns/1ns

module pingpongram_tb(output logic [7:0] dataRead, output logic writeEnable); 


  parameter CLK_PERIOD = 40;
  logic rst;
reg clk;
//logic clk_25MHz;
reg [18:0] addrWrite;
reg [9:0] hc_out;
reg [9:0] vc_out;
reg [7:0] dataWrite;

logic [35:0] fake_frequencies[0:15];

// graphics TESTER(hc_out, vc_out, fake_frequencies, 
	 PingPongRam TEST(clk, rst, addrWrite, hc_out, vc_out, dataWrite, dataRead, writeEnable);
always begin

    #((CLK_PERIOD / 2)) clk = ~clk;
  end
  
 initial begin
clk = 0;
 rst = 1;
 addrWrite = 0;
 hc_out = 0;
 vc_out = 0;
 dataWrite = 8'b11100011;
 
 
 
 #100
 
 hc_out = 41;
 vc_out = 0;
 dataWrite = 8'b11111111;
 addrWrite = (0/24) * 16 + hc_out/40;
 
 #100
 
 hc_out = 72;
 vc_out = 32;
 dataWrite = 8'b10101010;
 addrWrite = (32/24) * 16 + hc_out/40; 
 
 $stop;
 
 end

	 

	
	 endmodule