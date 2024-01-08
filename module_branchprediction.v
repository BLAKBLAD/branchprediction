`timescale 1ns / 1ps

//更新使能train_valid：1-更新，0-不更新
//是/不是分支指令isbranch：1-是分支指令，0-不是分支指令
//跳转结果taken：1-是分支指令且确实发生了跳转，0-是分支指令但是没有发生跳转

module module_branchprediction(
    input clk,
    input rst,
    input [31:0] PC0,
    input [31:0] PC1,
    input train_valid0,
    input train_valid1,
    input isbranch0,
    input isbranch1,
    input [31:0] address_branch0,
    input [31:0] address_branch1,
    input [31:0] address_result0,
    input [31:0] address_result1,
    input taken0,
    input taken1,
    output [31:0] target0,
    output [31:0] target1
    );
    
    //调用module_gselect
    module_gselect modulex(.clk(clk), .rst(rst), .PC0(PC0), .PC1(PC1), .train_valid0(train_valid0), 
    .train_valid1(train_valid1), .isbranch0(isbranch0), .isbranch1(isbranch1), 
    .address_branch0(address_branch0), .address_branch1(address_branch1), 
    .address_result0(address_result0), .address_result1(address_result1), 
    .taken0(taken0), .taken1(taken1), 
    .target0(target0), .target1(target1)
    );
    
endmodule
