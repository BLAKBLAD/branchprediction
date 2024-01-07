`timescale 1ns / 1ps

//taken 上一条指令预测的结果，1-是跳转指令且跳转成功
//target 跳转地址

module module_branchprediction(
    input clk,
    input rst,
    input [6:0] opcode,
    input [31:0] currentPC,
    input update,
    input [31:0] branchPC,
    input [31:0] resultPC,
    input taken,
    output [31:0] target
    );
    
    //调用module_gselect
    module_gselect modulex(.clk(clk), .isbranch(isbranch), .update(update), 
    .lastPC(lastPC), .currentPC(currentPC), .taken(taken), .target(target));
    
endmodule
