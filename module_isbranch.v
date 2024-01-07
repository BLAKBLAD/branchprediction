`timescale 1ns / 1ps

module module_isbranch(
    input [6:0] opcode,
    output isbranch
    );
    
    assign isbranch = opcode == 7'b1100011;
    
endmodule