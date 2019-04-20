`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Alec Meade 
// 
// Create Date: 02/15/2018 02:51:27 PM
// Design Name: 
// Module Name: Alec HW3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module bit( //one bit register

input clk, 
input rst, 
input load,
input [1:0] data,
output [1:0] q
);
reg [1:0] q;

always @ (posedge clk)
if (rst)
q = 0; //set 0 
else
if(load)
q = data; //if load is true then assign data to q 

endmodule

module reg16(
input rst,
input load,
input clk, 
input [15:0] data,
output [15:0] q);

reg [15:0] q;
genvar i; //instantation must be done outside of always blocks because must be indepentant of any edges 
generate 
for(i=0;i<16;i=i+1)
 bit reg1 (clk, rst, load, data[i], q[i]); //create 1 bit module
    begin:generate_reg16 //generate 16 modules 
    end
endgenerate

  always @(posedge clk)
    if (rst)
            q = 0; //set all of q to 0 
    else
            if(load)
            q = data; // if load is true set all of q to data like in 1 bit 
endmodule

module ram8bit(
input [15:0] data,
input load,
input [3:0] address, //2^3 = 8 
input clk,
output reg [15:0] out //can declare reg in constructor 
);

reg [15:0] ram8 [0:7]; // 8 slots of 16 bit ram 
always @(posedge clk) 
begin
    if(load)
    begin
        ram8[address] <= data; //assign the data to the one of 8 address values  
     end
     out <= ram8[address]; //set the the output to the ram value at that address 
end
endmodule 

module ram64(
input [15:0] data,
input load, 
input [6:0] address, // 2^6 = 64 
input clk,
output reg [15:0] out //can declare reg in constructor 
);

reg [15:0] ram64 [0:63]; // 64 slots of 16 bit ram 
always @(posedge clk) 
begin
    if(load)
    begin
        ram64[address] <= data; //assign the data to the one of 64 address values 
     end
     out <= ram64[address]; //set the the output to the ram value at that address 
end
endmodule 

module PC( 
input [15:0] next, //dont declare as reg 
input load,  
input reset ,
input inc,
input clk,
output [15:0] result);

reg [15:0] result; //only declare outs as regs 

always @(posedge clk or reset) //each one needs its own always block apparently 
begin 
   if(reset) 
        begin 
             result = 0;  //if reset turn pc to 0 
        end 
end
always @(posedge clk or load)
begin
    if(load)
        begin 
             result <= next; //if load set pc to next load input  
        end 
end  
always @(posedge clk or inc)  
begin         
     if(inc) 
        begin 
             result <= result + 1; //if inc set just add 1 to current pc 
         end
end 
endmodule 
