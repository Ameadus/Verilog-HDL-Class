`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Created by Alexander Meade
// Create Date: 01/23/2018 02:21:14 PM
// Design Name: 
// Module Name: Project 1
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


module HW1(input clk, Vcc, rst ,output q11);

wire w1 , w2, q0, q1,q2,q3,q4; 
tff_async T1 (Vcc, clk , ~rst, q0);
tff_async T2 (q0, clk , ~rst, q1);
tff_async T3 (q1, lk , ~rst, q2);
tff_async T4 (q2, clk , ~rst, q3);
and a1 (w1,~q0,q1,q2,~q3); //gate format is a1 instance w1 output other 5 input
or o1(w2, w1, q4);
tff_async T5 (w2, clk , ~rst, q4);
assign qb = ~q4; 

endmodule


module tff_async(input Vcc , Clk , rst ,output reg q );

//flip flop logic 
always @ ( posedge Clk or negedge rst) begin
if(~rst) begin
    q <= ! 1'b1 ;
    end else if (Vcc) begin 
    q <= !q;
    end
end
endmodule
