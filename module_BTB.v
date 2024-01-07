`timescale 1ns / 1ps

module module_BTB(
    input clk,
    input rst,
    input isbranch,
    input [31:0] currentPC,
    input update,
    input [31:0] branchPC,
    input [31:0] resultPC,
    input taken,
    output [31:0] target
    );
    
    //四路组相联
    reg [63:0] BTB [255:0][3:0];
    reg valid [255:0][3:0];
    reg [1:0] LRU [255:0][3:0];
    reg [31:0] nextPC;
    reg [3:0] match_4bit;
    reg [2:0] match;
    integer i, j;
    
    //LRU替换策略，暂时无法运行，需要拆成三个时钟才能干完
    always @(posedge clk)begin
        if(rst)begin
            for(i = 0; i < 256; i = i + 1)begin
                for(j = 0; j < 4; j = j + 1)begin
                    valid[i][j] <= 0;
                end
            end
        end
        else begin
            if(!isbranch)
                nextPC <= currentPC + 4;
            else begin
                if(update)begin
                    if(taken)begin
                        for(i = 0; i < 4; i = i + 1)begin
                            match_4bit[i] <= valid[branchPC[7:0]][i] && 
                            BTB[branchPC[7:0]][i][63:32] == branchPC;
                        end
                        casez(match_4bit)
                            4'bzzz1: match <= 0;
                            4'bzz10: match <= 1;
                            4'bz100: match <= 2;
                            4'b1000: match <= 3;
                            default: match <= 4;
                        endcase
                        if(match < 4)begin
                            for(i = 0; i < 4; i = i + 1)begin
                                if(i != match && LRU[branchPC[7:0]][i] != 2'b00 && 
                                LRU[branchPC[7:0]][i] > LRU[branchPC[7:0]][match])
                                    LRU[branchPC[7:0]][i] <= LRU[branchPC[7:0]][i] - 1;
                            end
                            LRU[branchPC[7:0]][match] <= 2'b11;
                            BTB[branchPC[7:0]][match][31:0] <= resultPC;
                        end
                        else begin
                            for(i = 0; i < 4; i = i + 1)begin
                                match_4bit[i] <= valid[branchPC[7:0]][i] == 0 || LRU[branchPC[7:0]][i] == 2'b00;
                            end
                            casez(match_4bit)
                                4'bzzz1: match <= 0;
                                4'bzz10: match <= 1;
                                4'bz100: match <= 2;
                                4'b1000: match <= 3;
                                default: match <= 4;
                            endcase
                            for(i = 0; i < 4; i = i + 1)begin
                                if(i != match && LRU[branchPC[7:0]][i] != 2'b00 && LRU[branchPC[7:0]][i] > LRU[branchPC[7:0]][match])
                                    LRU[branchPC[7:0]][i] <= LRU[branchPC[7:0]][i] - 1;
                            end
                            valid[branchPC[7:0]][match] <= 1;                 
                            LRU[branchPC[7:0]][match] <= 2'b11;               
                            BTB[branchPC[7:0]][match] <= {branchPC, resultPC};
                        end
                    end
                    else begin
                        for(i = 0; i < 4; i = i + 1)begin
                            match_4bit[i] <= valid[branchPC[7:0]][i] != 0 && BTB[branchPC[7:0]][i][63:32] == branchPC;
                        end
                        casez(match_4bit)
                            4'bzzz1: match <= 0;
                            4'bzz10: match <= 1;
                            4'bz100: match <= 2;
                            4'b1000: match <= 3;
                            default: match <= 4;
                        endcase
                        if(match < 4)begin                    
                            for(i = 0; i < 4; i = i + 1)begin
                                if(i != match && valid[branchPC[7:0]][i] == 1 && LRU[branchPC[7:0]][i] != 2'b11)
                                    LRU[branchPC[7:0]][i] <= LRU[branchPC[7:0]][i] + 1;
                            end
                            LRU[branchPC[7:0]][i] <= 2'b00;
                            valid[branchPC[7:0]][i] <= 0;
                        end
                    end
                end
                for(i = 0; i < 4; i = i + 1)begin
                    match_4bit[i] <= valid[currentPC[7:0]][i] != 0 && 
                    BTB[currentPC[7:0]][i][63:32] == currentPC;
                end
                casez(match_4bit)
                    4'bzzz1: match <= 0;
                    4'bzz10: match <= 1;
                    4'bz100: match <= 2;
                    4'b1000: match <= 3;
                    default: match <= 4;
                endcase
                if(match < 4)
                    nextPC <= BTB[currentPC[7:0]][i][31:0];
                else
                    nextPC <= currentPC + 4;
            end
        end
    end

    assign target = nextPC;
        
endmodule
