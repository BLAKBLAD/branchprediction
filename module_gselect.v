`timescale 1ns / 1ps

module module_gselect(
    input clk,
    input rst,
    input [6:0] opcode,
    input [31:0] currentPC,
    input update,
    input [31:0] branchPC,
    input [31:0] resultPC,
    input taken,
    output target
    );
    
    wire output_module_isbranch;
    wire [7:0] output_module_GHR;
    wire output_module_PHT;
    
    module_isbranch module_0(.opcode(opcode), .isbranch(output_module_isbranch));
    
    module_GHR module_1(.clk(clk), .rst(rst), .update(update), .GHR(output_module_GHR));
    
    module_setofPHT module_2(.clk(clk), .rst(rst), .update(update), .BHR(output_module_GHR), 
    .branchPC_lower(branchPC[9:2]), .currentPC_lower(currentPC[9:2]), .taken(taken), 
    .taken_predict(output_module_PHT));
    
    module_BTB_direct module_3(.clk(clk), .rst(rst), .isbranch(output_module_isbranch), 
    .currentPC(currentPC), .update(update), .branchPC(branchPC), .resultPC(resultPC), 
    .target(target));
    
endmodule
