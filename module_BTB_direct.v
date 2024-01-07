`timescale 1ns / 1ps

module module_BTB_direct(
    input clk,
    input rst,
    input isbranch,
    input [31:0] currentPC,
    input update,
    input [31:0] branchPC,
    input [31:0] resultPC,
    output [31:0] target
    );
    
    //÷±Ω””≥…‰
    reg [63:0] BTB [1023:0];
    reg valid [1024:0];
    reg [31:0] nextPC;
    integer i;
    
    always @(posedge clk)begin
        if(rst)begin
            for(i = 0; i < 1024; i = i + 1)begin
                valid[i] <= 0;
            end
        end
        else begin
            if(!isbranch)begin
                nextPC <= currentPC + 4;
            end
            else begin
                if(update)begin
                    valid[branchPC[11:2]] <= 1;
                    BTB[branchPC[11:2]] <= {branchPC, resultPC};
                    if(branchPC == currentPC)begin
                        nextPC <= resultPC;
                    end
                    else begin
                        nextPC <= valid[branchPC[11:2]] ? 
                        BTB[currentPC[11:2]][31:0] : nextPC <= currentPC + 4;
                    end
                end
                else begin
                    nextPC <= valid[branchPC[11:2]] ? 
                    BTB[currentPC[11:2]][31:0] : nextPC <= currentPC + 4;
                end
            end
        end
    end

    assign target = nextPC;
endmodule
