`timescale 1ns / 1ps

//taken ��һ��ָ��Ԥ��Ľ����1-����תָ������ת�ɹ�
//target ��ת��ַ

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
    
    //����module_gselect
    module_gselect modulex(.clk(clk), .isbranch(isbranch), .update(update), 
    .lastPC(lastPC), .currentPC(currentPC), .taken(taken), .target(target));
    
endmodule
