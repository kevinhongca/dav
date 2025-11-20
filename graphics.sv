
module graphics (
input switch,
input clk,
    input [9:0] hc_out,
    input [9:0] vc_out,
	 input [35:0] processed_fft_data[0:15],
	 input done,
    output reg [7:0] color,
    output reg [9:0] addrWrite,
	 output reg [6:0] colorAdder
);

localparam HORIZ_BLOCK_SIZE = 16; 
localparam VERT_BLOCK_SIZE = 20; //so now we have 16x20 blocks 
localparam SCREEN_WIDTH = 640 / HORIZ_BLOCK_SIZE; // adjust for blocking
localparam SCREEN_HEIGHT = 480 / VERT_BLOCK_SIZE; 
logic [35 :0] past_data[0:15];
logic [35 :0] past_data1[0:15];
logic [35:0] past_data2 [0:15];
logic [35:0] past_data3 [0:15];
logic [35:0] past_data4 [0:15]; 
logic [35:0] past_data5 [0:15];
logic [35:0] past_data6 [0:15];
logic [35:0] past_data7 [0:15];
logic [35:0] past_data8 [0:15];
logic [35:0] past_data9 [0:15];
logic [35:0] past_data10 [0:15];
logic [35:0] past_data11 [0:15];
logic [35:0] past_data12 [0:15];
logic [35:0] past_data13 [0:15];
logic [35:0] past_data14 [0:15];
integer binInterest; 
logic [9:0] scaledOutput; 
logic [7:0] backgroundColor;
//logic [6:0] colorAdder;


always_ff @(posedge clk) begin



if (!switch) begin
if (hc_out == 0 && vc_out == 0) begin
backgroundColor <= backgroundColor + 1;

end

else begin
backgroundColor <= backgroundColor;
if (hc_out == 0 && vc_out == 0) begin

colorAdder <= colorAdder + 1;
end
end

end
else begin
backgroundColor <= 0;

end

if (done) begin



past_data <= processed_fft_data;
past_data1 <= past_data;
past_data2<= past_data1;
past_data3 <= past_data2;
past_data4 <= past_data3;
past_data5 <= past_data4;
past_data6 <= past_data5;
past_data7 <= past_data6;
past_data8 <= past_data7;
past_data9 <= past_data8;
past_data10 <= past_data9;
past_data11 <= past_data10;
past_data12 <= past_data11;
past_data13 <= past_data12;
past_data14 <= past_data13;



end


else begin



past_data <= past_data;
past_data1 <= past_data1;
past_data2 <= past_data2;
past_data3 <= past_data3;
past_data4 <= past_data4;
past_data5 <= past_data5;
past_data6 <= past_data6;
past_data7 <= past_data7;
past_data8 <= past_data8;
past_data9 <= past_data9;
past_data10 <= past_data10;
past_data11 <= past_data11;
past_data12 <= past_data12;
past_data13 <= past_data13;
past_data14 <= past_data14;
//past_data15 <= past_data15;
//past_data4 <= past_data4;
//past_data5 <= past_data5;


end

end
/*
always @(posedge done) begin






past_data[0] <= processed_fft_data[0];
past_data[1] <= processed_fft_data[1];
past_data[2] <= processed_fft_data[2];
past_data[3] <= processed_fft_data[3];
past_data[4] <= processed_fft_data[4];
past_data[5] <= processed_fft_data[5];
past_data[6] <= processed_fft_data[6];
past_data[7] <= processed_fft_data[7];
past_data[8] <= processed_fft_data[8];
past_data[9] <= processed_fft_data[9];
past_data[10] <= processed_fft_data[10];
past_data[11] <= processed_fft_data[11];
past_data[12] <= processed_fft_data[12];
past_data[13] <= processed_fft_data[13];
past_data[14] <= processed_fft_data[14];
past_data[15] <= processed_fft_data[15];


end*/
always_comb begin


binInterest =  hc_out/(640/HORIZ_BLOCK_SIZE);
scaledOutput =  (past_data[binInterest][27:18] +    past_data1[binInterest][27:18] +
past_data2[binInterest][27:18] + past_data3[binInterest][27:18] + past_data4[binInterest][27:18] +
past_data5[binInterest][27:18] + past_data6[binInterest][27:18] +    past_data7[binInterest][27:18] +
past_data8[binInterest][27:18] + past_data9[binInterest][27:18] + past_data10[binInterest][27:18] +
past_data11[binInterest][27:18] + past_data12[binInterest][27:18] +    past_data13[binInterest][27:18] +
past_data14[binInterest][27:18])/15    ; 
	 color = 8'b00100100; // default value
	 addrWrite = 18'b000000000000000000; //default value (will change later), but we put it here just in case
	 
    if (hc_out / 40 < 16 && vc_out / 24 < 20) begin
      // if ( done) begin
	
		  
		  if (480 - (scaledOutput   )  <= vc_out && ((-1)*vc_out +480)/ 24 < 7) begin
		 
	color[4:2] = 3'b001 +  (((-1)*vc_out +480)/ 24) + colorAdder;
	color[7:5] = 3'b000;
	color[1:0] = 2'b00;
	end
	
	else if (480- (scaledOutput ) <= vc_out && ((-1)*vc_out +480)/ 24 < 14) begin
	color[7:5] = 3'b001 +  ((((-1)*vc_out +480)/ 24) - 7) + colorAdder;
	color[4:2] = 3'b111 + colorAdder;
	color[1:0] = 2'b00;
	
	end
	else if (480 - (scaledOutput)  <= vc_out) begin
	color[7:5] = 3'b111 + colorAdder;
	color[4:2] = 3'b111 + colorAdder;
	color[1:0] = 2'b00 + ((((-1)*vc_out +480)/ 24) - 14) + colorAdder;
	
	end
	else begin
	
	color[7:0] = backgroundColor;
	end
		
		
		  
	
	   addrWrite = (vc_out / 24) *  16 + (hc_out / 40);
	//  past_data[binInterest] = color;
		 
		 // end 
	/*	 else begin
		 addrWrite = 0;//(vc_out / 24) *  16 + (hc_out / 40);
		  color =      backgroundColor; // past_data[addrWrite]; // Purple, allegedly
		  
		  end*/
     
		  
		  
		  end
		  
		  
	/*	  color = 8'b11100011;
		 addrWrite = (vc_out / 24) *  16 + (hc_out / 40);
		 end
		  else begin
		  
		  color = 0;
		  addrWrite = 0;
		  end
		   
    end*/
    else begin
        color = 8'b00000000;
        addrWrite = 0;
    end
end

endmodule
