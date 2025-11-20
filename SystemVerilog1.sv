module memory_controller(clk, done, addrWrite, colorAdder, dataWrite, addrRead_h, addrRead_v, dataRead);
// ping pong :D
    input clk;
	 input done;
    input [9:0] addrWrite;
	 input [6:0] colorAdder;
    input [7:0] dataWrite;

    input [9:0] addrRead_h;
    input [9:0] addrRead_v;
    output reg [7:0] dataRead;

    wire [9:0] addrRead;
    assign addrRead = (addrRead_h / 40) + (addrRead_v / 24) * 16;

    reg [9:0] addrA, addrB;
    
    wire [7:0] outputA;
    wire [7:0] outputB;

	 logic [7:0] combined; 
    ram ramA(addrA, clk, dataWrite, writeEnableA, outputA);
    ram ramB(addrB, clk, dataWrite, writeEnableB, outputB);

    reg writeEnableA = 1'b1;
    wire writeEnableB;
    assign writeEnableB = ~writeEnableA;

    always @(posedge clk) begin
        if (addrRead_h == 0 && addrRead_v == 0) begin
            writeEnableA <= ~writeEnableA;
        end
		//  combined <= dataWrite + colorAdder;
    end

    always_comb begin
	
        if (writeEnableA) begin
		  //if (done) begin
            addrA = addrWrite;
            addrB = addrRead;
				
				
			//	end
            dataRead = outputB;
        end
        else begin
		  
		//  if (done) begin
            addrA = addrRead;
            addrB = addrWrite;
			//	end
            dataRead = outputA;
        end
    end
endmodule