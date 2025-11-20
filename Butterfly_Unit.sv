module Butterfly_Unit #(parameter WIDTH=36)(
  input logic signed [WIDTH-1:0] A,
  input logic signed [WIDTH-1:0] B,
  input logic signed [WIDTH-1:0] W,
  output logic signed [WIDTH-1:0] sum,
  output logic signed [WIDTH-1:0] diff
);

  // Make real and imaginary components
  logic signed [WIDTH/2-1:0] A_real, A_imag;
  logic signed [WIDTH/2-1:0] B_real, B_imag;
  logic signed [WIDTH/2-1:0] W_real, W_imag;
  logic signed [WIDTH/2-1:0] sum_real, sum_imag;
  logic signed [WIDTH/2-1:0] diff_real, diff_imag;

  // Split each input & output into its real and imaginary components
  assign A_real = A[WIDTH-1:WIDTH/2]; 
  assign A_imag = A[WIDTH/2-1:0];

  assign B_real = B[WIDTH-1:WIDTH/2];
  assign B_imag = B[WIDTH/2-1:0];

  assign W_real = W[WIDTH-1:WIDTH/2];
  assign W_imag = W[WIDTH/2-1:0];

  assign sum[WIDTH-1:WIDTH/2] = sum_real;
  assign sum[WIDTH/2-1:0] = sum_imag ;

  assign diff[WIDTH-1:WIDTH/2] = diff_real ;
  assign  diff[WIDTH/2-1:0]=diff_imag;

  // Make real and imaginary components for B*W
  logic signed [WIDTH-1:0] BW_real;
  logic signed [WIDTH-1:0] BW_imag;
  logic signed [WIDTH/2-1:0] BW_real_t, BW_imag_t;

  // After calculation, discard first bit and last 17 bits (see diagram)
  assign BW_real_t = BW_real[34:17];
  assign BW_imag_t = BW_imag[34:17];

  always_comb begin
    // Perform FOIL method 
   BW_real = B_real * W_real - B_imag * W_imag;
   BW_imag = B_real * W_imag + B_imag * W_real;
    
    // Sum_real and sum_imag make up sum
   sum_imag = A_imag + BW_imag_t;
   sum_real = A_real + BW_real_t; 
    
    // Diff_real and diff_imag make up diff
   diff_real = A_real - BW_real_t;
   diff_imag = A_imag - BW_imag_t;
	
  end
 
endmodule