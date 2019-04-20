/* 
 * Testbench for simple 8-bit CPU.
*/

// Added small program memory for simulation
module programmem(input [7:0] pgmaddr, output [7:0] pgmdata);
  reg [7:0] pmemory[0:255]; //255:0
  assign pgmdata=pmemory[pgmaddr];

  initial
    begin
      pmemory[0]=8'hD0;  // load from next location 
      pmemory[1]=8'h0A;
     // pmemory[2]=8'h20;  // NOT
      pmemory[3]=8'h90;  // jump to 2 (or 0 to reload)
      pmemory[4]=8'h00;
    end
endmodule

// Simple user memory for simulation
module usermem(input clk, input [7:0] uaddr, inout [7:0] udata, input rw);
  reg [7:0] umemory[0:255];
  assign udata=rw?8'bz:umemory[uaddr];
  always @(negedge clk) 
    if (rw==1) umemory[uaddr]<=udata;
  
  initial
   begin
     umemory[0]=8'h00;
     umemory[1]=8'h33;
     umemory[2]=8'hAA;
   end
endmodule

module cpu_tb;
        reg clk, reset, interrupt;
  wire [7:0] datamem_data, usermem_data, datamem_address, usermem_address;
	wire rw;
  programmem pgm(datamem_address,datamem_data);
  usermem umem(clk, usermem_address,usermem_data,rw);
  cpu dut0(clk, reset, interrupt, datamem_data, usermem_data, 
                 datamem_address, usermem_address, rw);
        initial
        begin
          $display("NopCPU testbench. All waveforms will be dumped to the dump.vcd file.");
		clk = 1'b0;
		reset = 1'b1;
		interrupt = 1'b0;
		//repeat(4) #10 clk = !clk;
		#5
		reset = 1'b0;
        end
        
        always
                #1 clk = !clk;
	//always
		//#20 interrupt = ~interrupt;
   initial
      #5000 $finish;
endmodule //cpu_tb
