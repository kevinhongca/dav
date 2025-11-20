`timescale 1ns/1ns

module Butterfly_Unit_tb #(parameter WIDTH = 36)(
  output logic signed [WIDTH-1:0] sumTest,
  output logic signed [WIDTH-1:0] diffTest
);
  
  reg [WIDTH-1:0] inputA;
  reg [WIDTH-1:0] inputB;
  
  reg [WIDTH-1:0] twiddleOne; //= 32'b01111111111111110000000000000000
  
  //one for w = - j
  
 
  Butterfly_Unit #(WIDTH) TEST(inputA, inputB, twiddleOne, sumTest, diffTest);
  
  initial begin
  //twiddleOne = 32'b011111111111111111000000000000000000;
  twiddleOne = 36'b010110101000001010010110101000001010; //testing 1
  inputA = 36'b000000000110001101000000000000000000; //100 real 0 imag
  inputB = 36'b000000000110001101000000000000000000; //100 real 0 imag
  
  #100
  
  /*
  for (integer i = 0; i < 2100; i = i + 100) begin
			for (integer j = 0; j < 2100; j = j + 100)  begin
				inputA = inputA + i;
				inputB = inputB + j;
				#5; // simulation delay
			end
		end
  
  
  
  
  inputA = 32'b00000000000000000000000001100100;
  inputB = 32'b00000000000000000000000001100100;
  
  
  twiddleOne = 32'b00000000000000000111111111111111;
    for (integer i = 0; i < 2100; i = i + 100) begin
			for (integer j = 0; j < 2100; j = j + 100)  begin
				inputA = inputA + i;
				inputB = inputB + j;
				#5; // simulation delay
			end
		end
  */
  $stop;
  end
  
  
  endmodule 