module FFT_16Point #(parameter WIDTH=36) (
	input logic signed [11:0] input0 [0:15], 
	input logic clk,
	input logic rst,
	input logic start,
	output logic signed [35:0] output0 [0:15],
	output logic done
);
logic signed [35:0] temp [0:15];
integer counter; 

//inputs always have to be updated through the combinational block
logic signed [WIDTH-1:0] input0_update; 
logic signed [WIDTH-1:0] input1_update;
logic signed [WIDTH-1:0] input2_update; 
logic signed [WIDTH-1:0] input3_update; 
logic signed [WIDTH-1:0] input4_update; 
logic signed [WIDTH-1:0] input5_update; 
logic signed [WIDTH-1:0] input6_update; 
logic signed [WIDTH-1:0] input7_update; 
logic signed [WIDTH-1:0] input8_update; 
logic signed [WIDTH-1:0] input9_update; 
logic signed [WIDTH-1:0] input10_update; 
logic signed [WIDTH-1:0] input11_update; 
logic signed [WIDTH-1:0] input12_update; 
logic signed [WIDTH-1:0] input13_update; 
logic signed [WIDTH-1:0] input14_update; 
logic signed [WIDTH-1:0] input15_update;

//updated inputs get assigned in the sequential block, 36 bits
logic signed [WIDTH-1:0] input0_current = 36'b000000000000000000000000000000000000;
logic signed [WIDTH-1:0] input1_current = 36'b000000000000000000000000000000000000; 
logic signed [WIDTH-1:0] input2_current = 36'b000000000000000000000000000000000000;
logic signed [WIDTH-1:0] input3_current = 36'b000000000000000000000000000000000000; 
logic signed [WIDTH-1:0] input4_current = 36'b000000000000000000000000000000000000; 
logic signed [WIDTH-1:0] input5_current = 36'b000000000000000000000000000000000000; 
logic signed [WIDTH-1:0] input6_current = 36'b000000000000000000000000000000000000; 
logic signed [WIDTH-1:0] input7_current = 36'b000000000000000000000000000000000000; 
logic signed [WIDTH-1:0] input8_current = 36'b000000000000000000000000000000000000; 
logic signed [WIDTH-1:0] input9_current = 36'b000000000000000000000000000000000000; 
logic signed [WIDTH-1:0] input10_current = 36'b000000000000000000000000000000000000; 
logic signed [WIDTH-1:0] input11_current = 36'b000000000000000000000000000000000000; 
logic signed [WIDTH-1:0] input12_current = 36'b000000000000000000000000000000000000; 
logic signed [WIDTH-1:0] input13_current = 36'b000000000000000000000000000000000000; 
logic signed [WIDTH-1:0] input14_current = 36'b000000000000000000000000000000000000; 
logic signed [WIDTH-1:0] input15_current = 36'b000000000000000000000000000000000000; 

//twiddle factors get declared, 36 bits
logic signed [WIDTH-1:0] twiddleZero = 36'b011111111111111111000000000000000000; //W0_8                                  
logic signed [WIDTH-1:0] twiddleOne = 36'b011101100100000111110011110000010001; //W1_8
logic signed [WIDTH-1:0] twiddleTwo = 36'b010110101000001010010110101000001010; //W2_8
logic signed [WIDTH-1:0] twiddleThree = 36'b001100001111101111100010011011111001; //W3_8
logic signed [WIDTH-1:0] twiddleFour = 36'b000000000000000000100000000000000001; //W4_8
logic signed [WIDTH-1:0] twiddleFive = 36'b110011110000010001100010011011111001; //W5_8
logic signed [WIDTH-1:0] twiddleSix = 36'b101001010111110110101001010111110110; //W6_8
logic signed [WIDTH-1:0] twiddleSeven = 36'b100010011011111001110011110000010001; //W7_8

logic [2:0] state = 3'b000; //current state
logic [2:0] next_state = 3'b000; //updates state

//six different states
localparam RESET = 3'b000;
localparam STAGE1 = 3'b001;
localparam STAGE2 = 3'b010;
localparam STAGE3 = 3'b011;
localparam STAGE4 = 3'b100;
localparam STAGE5 = 3'b101; //filler stage
localparam DONE = 3'b110;

logic done_update = 1'b0; //updates done

logic signed [WIDTH-1:0] twiddle_factorZero = 36'b011111111111111111000000000000000000; //current twiddle factor, 36 bits
logic signed [WIDTH-1:0] twiddle_factorOne = 36'b011111111111111111000000000000000000; 
logic signed [WIDTH-1:0] twiddle_factorTwo = 36'b011111111111111111000000000000000000;
logic signed [WIDTH-1:0] twiddle_factorThree = 36'b011111111111111111000000000000000000;
logic signed [WIDTH-1:0] twiddle_factorFour = 36'b011111111111111111000000000000000000;
logic signed [WIDTH-1:0] twiddle_factorFive = 36'b011111111111111111000000000000000000;
logic signed [WIDTH-1:0] twiddle_factorSix = 36'b011111111111111111000000000000000000;
logic signed [WIDTH-1:0] twiddle_factorSeven = 36'b011111111111111111000000000000000000;

logic signed [WIDTH-1:0] twiddle_updateZero = 36'b011111111111111111000000000000000000; //updates twiddle factor (next twiddle factor), 36 bits
logic signed [WIDTH-1:0] twiddle_updateOne = 36'b011111111111111111000000000000000000;
logic signed [WIDTH-1:0] twiddle_updateTwo = 36'b011111111111111111000000000000000000;
logic signed [WIDTH-1:0] twiddle_updateThree = 36'b011111111111111111000000000000000000;
logic signed [WIDTH-1:0] twiddle_updateFour = 36'b011111111111111111000000000000000000;
logic signed [WIDTH-1:0] twiddle_updateFive = 36'b011111111111111111000000000000000000; 
logic signed [WIDTH-1:0] twiddle_updateSix = 36'b011111111111111111000000000000000000; 
logic signed [WIDTH-1:0] twiddle_updateSeven = 36'b011111111111111111000000000000000000;
//logic signed [35:0] output0 [0:15];
//Butterfly Units
//CHANGE OUTPUT INDEXES LATER
Butterfly_Unit #(WIDTH) bu0(input0_current, input8_current, twiddle_factorZero, output0[0], output0[8]); 
Butterfly_Unit #(WIDTH) bu1(input4_current, input12_current, twiddle_factorOne, output0[1], output0[9]);
Butterfly_Unit #(WIDTH) bu2(input2_current, input10_current, twiddle_factorTwo, output0[2], output0[10]);
Butterfly_Unit #(WIDTH) bu3(input6_current, input14_current, twiddle_factorThree, output0[3], output0[11]);
Butterfly_Unit #(WIDTH) bu4(input1_current, input9_current, twiddle_factorFour, output0[4], output0[12]);
Butterfly_Unit #(WIDTH) bu5(input5_current, input13_current, twiddle_factorFive, output0[5], output0[13]);
Butterfly_Unit #(WIDTH) bu6(input3_current, input11_current, twiddle_factorSix, output0[6], output0[14]);
Butterfly_Unit #(WIDTH) bu7(input7_current, input15_current, twiddle_factorSeven, output0[7], output0[15]);


initial begin
	done = 1'b0;
end

always @(posedge clk) begin
if (counter == 'd25000) begin

counter <= 0;

end


else begin
counter <= counter + 1;

end
	state <= next_state;
	done <= done_update;
	twiddle_factorZero <= twiddle_updateZero;
	twiddle_factorOne <= twiddle_updateOne;
	twiddle_factorTwo <= twiddle_updateTwo;
	twiddle_factorThree <= twiddle_updateThree;
	twiddle_factorFour <= twiddle_updateFour;
	twiddle_factorFive <= twiddle_updateFive;
	twiddle_factorSix <= twiddle_updateSix;
	twiddle_factorSeven <= twiddle_updateSeven;
	input0_current <= input0_update;
	input1_current <= input1_update;
	input2_current <= input2_update;
	input3_current <= input3_update;
	input4_current <= input4_update;
	input5_current <= input5_update;
	input6_current <= input6_update;
	input7_current <= input7_update;
	input8_current <= input8_update;
	input9_current <= input9_update;
	input10_current <= input10_update;
	input11_current <= input11_update;
	input12_current <= input12_update;
	input13_current <= input13_update;
	input14_current <= input14_update;
	input15_current <= input15_update;
/*	if (!done) begin
	temp[0] <= temp[0];
	temp[1] <= temp[1];
	
	temp[2] <= temp[2];
	
	temp[3] <= temp[3];
	
	temp[4] <= temp[4];
	temp[5] <= temp[5];
	temp[6] <= temp[6];
	temp[7] <= temp[7];
	temp[8] <= temp[8];
	temp[9] <= temp[9];
	temp[10] <= temp[10];
	temp[11] <= temp[11];
	temp[12] <= temp[12];
	temp[13] <= temp[13];
	temp[14] <= temp[14];
	temp[15] <= temp[15];
	//temp[0] <= temp[0];
	
	
	
	
	end
	
	else begin
	
	
	temp[0] <= output0[0];
	temp[1] <= output0[1];
	
	temp[2] <= output0[2];
	
	temp[3] <= output0[3];
	
	temp[4] <= output0[4];
	temp[5] <= output0[5];
	temp[6] <= output0[6];
	temp[7] <= output0[7];
	temp[8] <= output0[8];
	temp[9] <= output0[9];
	temp[10] <= output0[10];
	temp[11] <= output0[11];
	temp[12] <= output0[12];
	temp[13] <= output0[13];
	temp[14] <= output0[14];
	temp[15] <= output0[15];
	
	
	
	end
	
	*/
end

always_comb begin
	case (state)
		RESET: begin
			if (start == 1'b1) begin //when start input goes high
				next_state = STAGE1; //go to STAGE1
				
				done_update = 1'b0;
				twiddle_updateZero = twiddleZero;
				twiddle_updateOne = twiddleZero;
				twiddle_updateTwo = twiddleZero;
				twiddle_updateThree = twiddleZero;
				twiddle_updateFour = twiddleZero;
				twiddle_updateFive = twiddleZero;
				twiddle_updateSix = twiddleZero;
				twiddle_updateSeven = twiddleZero;
				
				input0_update = {{6{input0[0][11]}}, input0[0], 18'b0};
				input1_update = {{6{input0[1][11]}}, input0[1], 18'b0};
				input2_update = {{6{input0[2][11]}}, input0[2], 18'b0};
				input3_update = {{6{input0[3][11]}}, input0[3], 18'b0};
				input4_update = {{6{input0[4][11]}}, input0[4], 18'b0};
				input5_update = {{6{input0[5][11]}}, input0[5], 18'b0};
				input6_update = {{6{input0[6][11]}}, input0[6], 18'b0};
				input7_update = {{6{input0[7][11]}}, input0[7], 18'b0};
				input8_update = {{6{input0[8][11]}}, input0[8], 18'b0};
				input9_update = {{6{input0[9][11]}}, input0[9], 18'b0};
				input10_update = {{6{input0[10][11]}}, input0[10], 18'b0};
				input11_update = {{6{input0[11][11]}}, input0[11], 18'b0};
				input12_update = {{6{input0[12][11]}}, input0[12], 18'b0};
				input13_update = {{6{input0[13][11]}}, input0[13], 18'b0};
				input14_update = {{6{input0[14][11]}}, input0[14], 18'b0};
				input15_update = {{6{input0[15][11]}}, input0[15], 18'b0};
					
			end
			else begin
				next_state = RESET; //else do nothing
				
				done_update = 1'b0;
				twiddle_updateZero = twiddleZero;
				twiddle_updateOne = twiddleZero;
				twiddle_updateTwo = twiddleZero;
				twiddle_updateThree = twiddleZero;
				twiddle_updateFour = twiddleZero;
				twiddle_updateFive = twiddleZero;
				twiddle_updateSix = twiddleZero;
				twiddle_updateSeven = twiddleZero;
				
				input0_update = input0_current;
				input1_update = input1_current;
				input2_update = input2_current;
				input3_update = input3_current;
				input4_update = input4_current;
				input5_update = input5_current;
				input6_update = input6_current;
				input7_update = input7_current;
				input8_update = input8_current;
				input9_update = input9_current;
				input10_update = input10_current;
				input11_update = input11_current;
				input12_update = input12_current;
				input13_update = input13_current;
				input14_update = input14_current;
				input15_update = input15_current;
			end
		end
		STAGE1: begin
			//look at diagram
			input0_update = output0[0];
			input1_update = output0[4];
			input2_update = output0[2];
			input3_update = output0[6];
			input4_update = output0[8];
			input5_update = output0[12];
			input6_update = output0[10];
			input7_update = output0[14];
			input8_update = output0[1];
			input9_update = output0[5];
			input10_update = output0[3];
			input11_update = output0[7];
			input12_update = output0[9];
			input13_update = output0[13];
			input14_update = output0[11];
			input15_update = output0[15];
			
			next_state = STAGE2;
			done_update = 1'b0;
			twiddle_updateZero = twiddleZero;
			twiddle_updateOne = twiddleFour; 
			twiddle_updateTwo = twiddleZero;
			twiddle_updateThree = twiddleFour;
			twiddle_updateFour = twiddleZero;
			twiddle_updateFive = twiddleFour;
			twiddle_updateSix = twiddleZero;
			twiddle_updateSeven = twiddleFour;
			
		end
		STAGE2: begin
			//look at diagram
			input0_update = output0[0];
			input1_update = output0[4];
			input2_update = output0[8];
			input3_update = output0[12];
			input4_update = output0[1];
			input5_update = output0[5];
			input6_update = output0[9];
			input7_update = output0[13];
			input8_update = output0[2];
			input9_update = output0[6];
			input10_update = output0[10];
			input11_update = output0[14];
			input12_update = output0[3];
			input13_update = output0[7];
			input14_update = output0[11];
			input15_update = output0[15];
			
			next_state = STAGE3;
			done_update = 1'b0;
			twiddle_updateZero = twiddleZero;
			twiddle_updateOne = twiddleTwo; 
			twiddle_updateTwo = twiddleFour;
			twiddle_updateThree = twiddleSix;
			twiddle_updateFour = twiddleZero;
			twiddle_updateFive = twiddleTwo;
			twiddle_updateSix = twiddleFour;
			twiddle_updateSeven = twiddleSix;
		end
		STAGE3: begin
			//look at diagram
			input0_update = output0[0];
			input1_update = output0[8];
			input2_update = output0[2];
			input3_update = output0[10];
			input4_update = output0[1];
			input5_update = output0[9];
			input6_update = output0[3];
			input7_update = output0[11];
			input8_update = output0[4];
			input9_update = output0[12];
			input10_update = output0[6];
			input11_update = output0[14];
			input12_update = output0[5];
			input13_update = output0[13];
			input14_update = output0[7];
			input15_update = output0[15];
			
			next_state = STAGE4;
			done_update = 1'b0;
			twiddle_updateZero = twiddleZero;
			twiddle_updateOne = twiddleOne; 
			twiddle_updateTwo = twiddleTwo;
			twiddle_updateThree = twiddleThree;
			twiddle_updateFour = twiddleFour;
			twiddle_updateFive = twiddleFive;
			twiddle_updateSix = twiddleSix;
			twiddle_updateSeven = twiddleSeven;
		end
		STAGE4: begin
			//look at diagram
			input0_update = input0_current;
			input1_update = input1_current;
			input2_update = input2_current;
			input3_update = input3_current;
			input4_update = input4_current;
			input5_update = input5_current;
			input6_update = input6_current;
			input7_update = input7_current;
			input8_update = input8_current;
			input9_update = input9_current;
			input10_update = input10_current;
			input11_update = input11_current;
			input12_update = input12_current;
			input13_update = input13_current;
			input14_update = input14_current;
			input15_update = input15_current;
			
			next_state = STAGE5;
			done_update = 1'b0;
			twiddle_updateZero = twiddle_factorZero;
			twiddle_updateOne = twiddle_factorOne;
			twiddle_updateTwo = twiddle_factorTwo;
			twiddle_updateThree = twiddle_factorThree;
			twiddle_updateFour = twiddle_factorFour;
			twiddle_updateFive = twiddle_factorFive;
			twiddle_updateSix = twiddle_factorSix;
			twiddle_updateSeven = twiddle_factorSeven;
			
		end
		STAGE5: begin
			//filler stage so we can update ram 
			input0_update = input0_current;
			input1_update = input1_current;
			input2_update = input2_current;
			input3_update = input3_current;
			input4_update = input4_current;
			input5_update = input5_current;
			input6_update = input6_current;
			input7_update = input7_current;
			input8_update = input8_current;
			input9_update = input9_current;
			input10_update = input10_current;
			input11_update = input11_current;
			input12_update = input12_current;
			input13_update = input13_current;
			input14_update = input14_current;
			input15_update = input15_current;
			
			next_state = DONE;
			done_update = 1'b1;
			twiddle_updateZero = twiddle_factorZero;
			twiddle_updateOne = twiddle_factorOne;
			twiddle_updateTwo = twiddle_factorTwo;
			twiddle_updateThree = twiddle_factorThree;
			twiddle_updateFour = twiddle_factorFour;
			twiddle_updateFive = twiddle_factorFive;
			twiddle_updateSix = twiddle_factorSix;
			twiddle_updateSeven = twiddle_factorSeven;
			
		end
		DONE: begin
			if (rst == 1'b0) begin //if reset is pressed
				next_state = RESET;
				done_update = 1'b0; //not done
				
				twiddle_updateZero = twiddleZero; //reset back 
				twiddle_updateOne = twiddleZero;
				twiddle_updateTwo = twiddleZero;
				twiddle_updateThree = twiddleZero;
				twiddle_updateFour = twiddleZero;
				twiddle_updateFive = twiddleZero;
				twiddle_updateSix = twiddleZero;
				twiddle_updateSeven = twiddleZero;
				
				input0_update = {{6{input0[0][11]}}, input0[0], 18'b0};
				input1_update = {{6{input0[1][11]}}, input0[1], 18'b0};
				input2_update = {{6{input0[2][11]}}, input0[2], 18'b0};
				input3_update = {{6{input0[3][11]}}, input0[3], 18'b0};
				input4_update = {{6{input0[4][11]}}, input0[4], 18'b0};
				input5_update = {{6{input0[5][11]}}, input0[5], 18'b0};
				input6_update = {{6{input0[6][11]}}, input0[6], 18'b0};
				input7_update = {{6{input0[7][11]}}, input0[7], 18'b0};
				input8_update = {{6{input0[8][11]}}, input0[8], 18'b0};
				input9_update = {{6{input0[9][11]}}, input0[9], 18'b0};
				input10_update = {{6{input0[10][11]}}, input0[10], 18'b0};
				input11_update = {{6{input0[11][11]}}, input0[11], 18'b0};
				input12_update = {{6{input0[12][11]}}, input0[12], 18'b0};
				input13_update = {{6{input0[13][11]}}, input0[13], 18'b0};
				input14_update = {{6{input0[14][11]}}, input0[14], 18'b0};
				input15_update = {{6{input0[15][11]}}, input0[15], 18'b0};
				
				
			end
			else begin
				next_state = DONE;
				done_update = 1'b1; //done
				
				twiddle_updateZero = twiddle_factorZero;
				twiddle_updateOne = twiddle_factorOne;
				twiddle_updateTwo = twiddle_factorTwo;
				twiddle_updateThree = twiddle_factorThree;
				twiddle_updateFour = twiddle_factorFour;
				twiddle_updateFive = twiddle_factorFive;
				twiddle_updateSix = twiddle_factorSix;
				twiddle_updateSeven = twiddle_factorSeven;
				
				
				input0_update = input0_current;
				input1_update = input1_current;
				input2_update = input2_current;
				input3_update = input3_current;
				input4_update = input4_current;
				input5_update = input5_current;
				input6_update = input6_current;
				input7_update = input7_current;
				input8_update = input8_current;
				input9_update = input9_current;
				input10_update = input10_current;
				input11_update = input11_current;
				input12_update = input12_current;
				input13_update = input13_current;
				input14_update = input14_current;
				input15_update = input15_current;
				
				
			end
		end
		default: begin //we need a default case to cover all paths
			next_state = state;
			done_update = done;
			
			twiddle_updateZero = twiddle_factorZero;
			twiddle_updateOne = twiddle_factorOne;
			twiddle_updateTwo = twiddle_factorTwo;
			twiddle_updateThree = twiddle_factorThree;
			twiddle_updateFour = twiddle_factorFour;
			twiddle_updateFive = twiddle_factorFive;
			twiddle_updateSix = twiddle_factorSix;
			twiddle_updateSeven = twiddle_factorSeven;
			
			input0_update = input0_current;
			input1_update = input1_current;
			input2_update = input2_current;
			input3_update = input3_current;
			input4_update = input4_current;
			input5_update = input5_current;
			input6_update = input6_current;
			input7_update = input7_current;
			input8_update = input8_current;
			input9_update = input9_current;
			input10_update = input10_current;
			input11_update = input11_current;
			input12_update = input12_current;
			input13_update = input13_current;
			input14_update = input14_current;
			input15_update = input15_current;

		end
	endcase
end

endmodule	
			



