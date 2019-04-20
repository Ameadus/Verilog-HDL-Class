/*
This Verilog module describes a FSM which determines if the sequence of
bits it has seen so far is, if interpreted as a binary string where the
oldest value is the most significant bit and the newest value the least significant,
divisible by 4. 
*/

module FSM(input CLK, input RESET, input nextBit, output reg isDiv);
 
reg [1:0]state;
//declare any additional internal variables here

//synchronous always block (use <= for assignments!)
always @ (posedge CLK) begin
	
end		 

//next state and output combo logic block (use = for assignments!)
always @ (*) begin
	
end

endmodule