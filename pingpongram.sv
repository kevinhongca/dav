
module PingPongRam(
    input logic clk,
    input logic rst,
    input logic [18:0] addrWrite,
    input logic [9:0] addrRead_h, 
    input logic [9:0] addrRead_v, 
    input logic [7:0] dataWrite,   
    output logic [7:0] dataRead,
	output logic writeEnable 
);

localparam HORIZ_BLOCK_SIZE = 16; 
localparam VERT_BLOCK_SIZE = 20; 
localparam NEW_SCREEN_WIDTH = 640 / HORIZ_BLOCK_SIZE;
localparam NEW_SCREEN_HEIGHT = 480 / VERT_BLOCK_SIZE;
localparam NEW_RAM_SIZE = 20 * 16;

logic [7:0] ram1 [NEW_RAM_SIZE-1:0];
logic [7:0] ram2 [NEW_RAM_SIZE-1:0];

logic writeEnable_reg; 
assign writeEnable = writeEnable_reg;
/*initial begin
integer i;
for (i = 0; i < 8; i++) begin
ram1[i] = 0;
ram2[i] = 0;


end
dataRead = 0;
end*/
always_ff @(posedge clk) begin
    if (!rst) begin
        writeEnable_reg <= 0;
    end else if (addrRead_h == 0 && addrRead_v == 0) begin
        writeEnable_reg <= ~writeEnable_reg; // Toggle write enable
    end


    
end


    always_comb begin
	 
	 if (!writeEnable) begin
      ram1[addrWrite] = dataWrite;
		 dataRead = ram2[addrWrite]; //ram2[addrWrite];
    end else begin
       ram2[addrWrite] = dataWrite;
		 dataRead = ram1[addrWrite]; //ram1[addrWrite];
    end
	 
	 end

endmodule

