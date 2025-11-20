module FFT_4Point #(parameter WIDTH=32) (
	input logic signed [WIDTH-1:0] input0 [0:3],
	/*input logic signed [WIDTH-1:0] input1,
	input logic signed [WIDTH-1:0] input2,
	input logic signed [WIDTH-1:0] input3,*/
	input logic clk,
	input logic rst,
	input logic start,
	output logic signed [WIDTH-1:0] output0 [0:3],
	/*output logic signed [WIDTH-1:0] output1,
	output logic signed [WIDTH-1:0] output2,
	output logic signed [WIDTH-1:0] output3,*/
	output logic done
);

//inputs always have to be updated through the combinational block
 logic signed [WIDTH-1:0] input0_update ; // = 32b'00000000000000000000000000000000;//= input0;
logic signed [WIDTH-1:0] input1_update ; // = 32b'00000000000000000000000000000000;//= input1;
 logic signed [WIDTH-1:0] input2_update; // = 32b'00000000000000000000000000000000;// = input2;
 logic signed [WIDTH-1:0] input3_update ; // = 32b'00000000000000000000000000000000;// = input3;
 
 
//assign input0_update = input0;
//assign input1_update = input1;
//assign input2_update = input2;
//assign input3_update = input3;
//updated inputs get assigned in the sequential block
logic signed [WIDTH-1:0] input0_current = 32'b00000000000000000000000000000000;// = 32b'00000000000000000000000000000000;// = input0;
 logic signed [WIDTH-1:0] input1_current = 32'b00000000000000000000000000000000; //= 32b'00000000000000000000000000000000;// = input1;
 logic signed [WIDTH-1:0] input2_current = 32'b00000000000000000000000000000000; // = 32b'00000000000000000000000000000000;// = input2;
 logic signed [WIDTH-1:0] input3_current = 32'b00000000000000000000000000000000;// = 32b'00000000000000000000000000000000;// = input3;
	
//twiddle factors get declared
logic signed  [WIDTH-1:0] twiddleOne = 32'b01111111111111110000000000000000; //W0_4
                                     
logic signed [WIDTH-1:0] twiddleTwo =  32'b00000000000000001000000000000001; //W1_4
	
logic [1:0] state = 2'b00; //current state
logic [1:0] next_state = 2'b00; //updates state

logic done_update = 1'b0; //updates done
	
logic signed  [WIDTH-1:0] twiddle_factorOne = 32'b01111111111111110000000000000000; //current twiddle factor
logic signed [WIDTH-1:0] twiddle_factorTwo = 32'b01111111111111110000000000000000; 
logic signed  [WIDTH-1:0] twiddle_update = 32'b01111111111111110000000000000000; // = twiddleOne; //updates twiddle factor (next twiddle factor)
logic signed [WIDTH-1:0] twiddle_updateTwo = 32'b01111111111111110000000000000000; 

//initialize all outputs or else issues may arise 
initial begin
	/*output0 = 32'b00000000000000000000000000000000; //outputs are all set to 0
	output1 = 32'b00000000000000000000000000000000;
	output2 = 32'b00000000000000000000000000000000;
	output3 = 32'b00000000000000000000000000000000;*/
	done = 1'b0;
end
	
//need two butterfly units per state
ButterflyUnit #(WIDTH) bu1(input0_current, input2_current, twiddle_factorOne, output0[0], output0[2]); 
ButterflyUnit #(WIDTH) bu2(input1_current, input3_current, twiddle_factorTwo, output0[1], output0[3]);

//four different states
localparam RESET = 2'b00;
localparam STAGE1 = 2'b01;
localparam STAGE2 = 2'b10;
localparam DONE = 2'b11;

//sequential block
always @(posedge clk) begin
	state <= next_state;
	done <= done_update;
	twiddle_factorOne <= twiddle_update;
	twiddle_factorTwo <= twiddle_updateTwo;
	input0_current <= input0_update;
	input1_current <= input1_update;
	input2_current <= input2_update;
	input3_current <= input3_update;
end

always_comb begin
	case (state)
		RESET: begin
			if (start == 1'b1) begin //when start input goes high
				next_state = STAGE1; //go to STAGE1
				
				done_update = 1'b0;
				twiddle_update = twiddleOne;
				twiddle_updateTwo = twiddleOne;
				
				input0_update = input0[0];
				input1_update = input0[1];
				input2_update = input0[2];
				input3_update = input0[3];
				
			end
			else begin
				next_state = RESET; //else do nothing
				done_update = 1'b0;
				twiddle_update = twiddleOne;
				twiddle_updateTwo = twiddleOne;
				input0_update = input0_current;
				input1_update = input1_current;
				input2_update = input2_current;
				input3_update = input3_current;
			end
		end
		STAGE1: begin
			//look at diagram
			input0_update = output0[0];
			input1_update = output0[2];
			input2_update = output0[1];
			input3_update = output0[3];
			
			next_state = STAGE2;
			done_update = 1'b0;
			twiddle_update = twiddleOne;
			twiddle_updateTwo = twiddleTwo; //update the twiddle factor from W0_4 to W1_4
		end
		STAGE2: begin
			next_state = DONE;
			done_update = 1'b1; //the FFT is now done!
			twiddle_updateTwo = twiddleTwo;
			twiddle_update = twiddleOne;
			input0_update = input0_current;
			input1_update = input1_current;
			input2_update = input2_current;
			input3_update = input3_current;
			
		end
		DONE: begin
			if (rst == 1'b0) begin //if reset is pressed
				next_state = RESET;
				done_update = 1'b0; //not done
				twiddle_update = twiddleOne; //reset back to twiddleOne
				twiddle_updateTwo = twiddleOne;
				input0_update = input0[0];
				input1_update = input0[1];
				input2_update = input0[2];
				input3_update = input0[3];
				
			end
			else begin
				next_state = DONE;
				done_update = 1'b1; //done
				twiddle_updateTwo = twiddleTwo;
				twiddle_update = twiddleOne;
				
				input0_update = input0_current;
				input1_update = input1_current;
				input2_update = input2_current;
				input3_update = input3_current;
			end
		end
		default: begin //we need a default case to cover all paths
			next_state = state;
			done_update = done;
			twiddle_update = twiddle_factorOne;
			twiddle_updateTwo = twiddle_factorTwo;
			input0_update = input0_current;
			input1_update = input1_current;
			input2_update = input2_current;
			input3_update = input3_current;
		end
	endcase
end

endmodule	
			

