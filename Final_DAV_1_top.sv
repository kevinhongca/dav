module Final_DAV_1_top(
//	output reg clk
	input clk, 
	input switch,
	input adc_clk,
	input wire rst,     
	 output wire hsync,
	 output wire vsync,
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue,
	output [9:0] leds
);

logic clk_25MHz;
logic clk_4KHz;
logic outClock;
	 logic speed;
	
	logic [2:0] input_red;
	logic [2:0] input_green;
	logic [1:0] input_blue;
	
	logic [7:0] dataRead;
	logic [7:0] dataWrite;
	logic [9:0] addrWrite;
	
	assign input_red   = dataWrite[7:5]; 
	assign input_green = dataWrite[4:2];  
	assign input_blue  = dataWrite[1:0]; 
	 wire [9:0] hc_out, vc_out;

	wire [11:0] mic_output;
	//logic signed [35:0] mic_output_pad;
	adc1 mic_adc1(
		.CLOCK(adc_clk),
		.RESET(0),
		.CH0(mic_output)
	);
	//clock_divider clockTest(clk, rst, speed, outClock);

	logic signed [11:0] samples [0:15];
	logic signed [11:0] modSamples [0:15];
	
	//logic signed [35:0] samples [0:15];
	//logic signed [35:0] modSamples [0:15];
	logic signed [35:0] frequencies [0:15];
	logic signed [35:0] frequenciesDone [0:15];
	logic [6:0] hamming [0:15];
	logic [6:0] colorAdder;
	
	reg reset;
	reg start;
	wire done;
	
	assign leds = frequencies[10][27:18];
	FFT_16Point FFT_16 (
		modSamples,
		clk_4KHz,
		reset,
		start,
		frequencies,
		done
	);
	
	/*fft_16pt otherFFT (
	
	modSamples, clk_25MHz,
	reset, 
	start,
	clk_25MHz,
	frequencies,
	done
	
	);*/
	myPLL myPLL_instance(.inclk0 (clk),
	 .c0 (clk_25MHz));
	 thirdPLL secondPLL(.inclk0(clk), .c0(clk_4KHz));
	vga vga_instance(
	.vgaclk(clk_25MHz),
        .input_red(input_red),
        .input_green(input_green),
        .input_blue(input_blue),
        .rst(rst),
		  
        .hc_out(hc_out), 
        .vc_out(vc_out),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue)
	);
	/*
	PingPongRam ping(
		.clk(clk_25MHz), 
		.rst(rst),
		.addrWrite(addrWrite),
		.addrRead_h(hc_out),
		.addrRead_v(vc_out),
		.dataWrite(dataWrite),
		
		.dataRead(dataRead) 
	);*/
	memory_controller(clk_25MHz, done, addrWrite,colorAdder, dataWrite, hc_out, vc_out,  dataRead);
	graphics grap(
	.switch(switch),
	.clk(clk_25MHz),
		.hc_out(hc_out), 
		.vc_out(vc_out),
		.done(done),
		.processed_fft_data(frequenciesDone),
		.color(dataWrite), 
		.addrWrite(addrWrite),
		.colorAdder(colorAdder)
	);

	initial begin
//		clk = 0;
		reset = 0;
		start = 0;
		//speed = 26'd25000;
		
		samples[0] = 12'd000;
		samples[1] = 12'd000;
		samples[2] = 12'd000;
		samples[3] = 12'd000;
		samples[4] = 12'd000;
		samples[5] = 12'd000;
		samples[6] = 12'd000;
		samples[7] = 12'd000;
		samples[8] = 12'd000;
		samples[9] = 12'd000;
		samples[10] = 12'd000;
		samples[11] = 12'd000;
		samples[12] = 12'd000;
		samples[13] = 12'd000;
		samples[14] = 12'd000;
		samples[15] = 12'd000;
		hamming[0] = 7'b0001000;
		hamming[1] = 7'b0001100;
		hamming[2] = 7'b0010101;
		hamming[3]=7'b0100010;
		hamming[4]=7'b0110110;
		hamming[5]=7'b1001000;
		hamming[6]=7'b1010111;
		hamming[7]=7'b1100000;
		hamming[8]=7'b1100100;
		hamming[9] = 7'b1100000;
		hamming[10] = 7'b1010111;
		hamming[11] = 7'b1001000;
		hamming[12] = 7'b0110110;
		hamming[13] = 7'b0100010;
		hamming[14] = 7'b0010101;
		hamming[15] = 7'b0001100;
		modSamples[0] = 12'd000;
		modSamples[1] = 12'd000;
		modSamples[2] = 12'd000;
		modSamples[3] = 12'd000;
		modSamples[4] = 12'd000;
		modSamples[5] = 12'd000;
		modSamples[6] = 12'd000;
		modSamples[7] = 12'd000;
		modSamples[8] = 12'd000;
		modSamples[9] = 12'd000;
		modSamples[10] = 12'd000;
		modSamples[11] = 12'd000;
		modSamples[12] = 12'd000;
		modSamples[13] = 12'd000;
		modSamples[14] = 12'd000;
		modSamples[15] = 12'd000;
		#100 start = 1;
	end
	
/*	always begin
		#5 clk = ~clk;
	end */

//For the first tick of clk, I want to update sample[0] with the value of mic_output. 
//Then for the next tick of clk, I want to shift the value in sample[0] to sample[1], 
//and add the new value of mic_output to sample[0]. And so on.

/*
always_comb begin

mic_output_pad = {{6{mic_output[11]}}, mic_output, 18'b0};

end*/
   always @(posedge clk_4KHz) begin
	
        integer j;
       for (j = 15; j > 0; j = j - 1) begin
            samples[j] <= samples[j - 1]; //make the shift in samples
				modSamples[j] <=  (samples[j] * hamming[j] / 100)   ;
			//	modSamples[j] <= 54 * modSamples[j-1]/100 + 54*(samples[j]*hamming[j]/100 - samples[j-1]*hamming[j-1]/100)/100;
        end
        samples[0] <= mic_output; //update sample[0] with new mic output
		  modSamples[0] <= mic_output * hamming[0]/100;
   end
	
	always @(posedge clk_25MHz) begin
	
	if (done) begin
	frequenciesDone <= frequencies;
	
	
	end
	
	
	else
	frequenciesDone <= frequenciesDone;
	
	begin
	
	
	end
	
	
	end

endmodule