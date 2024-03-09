`timescale 1ns / 1ps

module module_gselect(
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
    
    reg [7:0] GHR;
    reg [1:0] PHT [255:0][255:0];//[1:0] PHT[2^widthofGHR-1:0][2^lowerbitsofPC-1:0]
    reg taken_predict0, taken_predict1;
    reg [63:0] BTB [1023:0];//direct mapping
    reg valid [1023:0];
    reg [31:0] nextPC0, nextPC1;
    integer i, j;
    
    //update GHR
    //在retire阶段更新GHR是比较滞后的，在预测后的下一个时钟应该立即根据PHT的预测结果做出一个预测性更新，retire阶段发现不对再改
    //但是这么写的时序bug有点多，先搁置
     always @(posedge clk) begin
        if(rst)begin
            GHR <= 0;
        end
        else begin
            if((train_valid0 && isbranch0) && (train_valid0 && isbranch0))begin
                GHR <= {GHR[5:0], taken0, taken1};
            end
            else if(train_valid0 && isbranch0)begin
                GHR <= {GHR[6:0], taken0};
            end
            else if(train_valid1 && isbranch1)begin
                GHR <= {GHR[6:0], taken1};
            end
            else begin
                GHR <= GHR;
            end
        end
    end
    
    //update PHT and get taken_predict
    always @(posedge clk) begin
        if(rst)begin
            /*cannot reset memory in one cycle
            for(i = 0; i < 256; i = i + 1)begin
                for(j = 0; j < 256; j = j + 1)begin
                    PHT[i][j] <= 0;
                end
            end
            */
        end
        else begin
            if(train_valid0)begin
                if(!isbranch0)begin
                    PHT[GHR][address_branch0[9:2]] <= 0;
                    taken_predict0 <= 0;
                end
                else if(taken0)begin
                    if(PHT[GHR][address_branch0[9:2]] != 2'b11)begin
                        PHT[GHR][address_branch0[9:2]] <= PHT[GHR][address_branch0[9:2]] + 1;
                        taken_predict0 <= PHT[GHR][address_branch0[9:2]][1] != 2'b00;
                    end
                end
                else begin
                    if(PHT[GHR][address_branch0[9:2]] != 2'b00)begin
                        PHT[GHR][address_branch0[9:2]] <= PHT[GHR][address_branch0[9:2]] - 1;
                        taken_predict0 <= PHT[GHR][address_branch0[9:2]][1] == 2'b11; 
                    end
                end
            end
            else begin
                PHT[GHR][address_branch0[9:2]] <= PHT[GHR][address_branch0[9:2]];
                taken_predict0 <= PHT[GHR][address_branch0[9:2]];
            end
            if(train_valid1)begin
                if(!isbranch1)begin
                    PHT[GHR][address_branch1[9:2]] <= 0;
                    taken_predict1 <= 0;
                end
                else if(taken1)begin
                    if(PHT[GHR][address_branch1[9:2]] != 2'b11)begin
                        PHT[GHR][address_branch1[9:2]] <= PHT[GHR][address_branch1[9:2]] + 1;
                        taken_predict1 <= PHT[GHR][address_branch1[9:2]][1] != 2'b00;
                    end
                end
                else begin
                    if(PHT[GHR][address_branch1[9:2]] != 2'b00)begin
                        PHT[GHR][address_branch1[9:2]] <= PHT[GHR][address_branch1[9:2]] - 1;
                        taken_predict1 <= PHT[GHR][address_branch1[9:2]][1] == 2'b11;
                    end
                end
            end
            else begin
                PHT[GHR][address_branch1[9:2]] <= PHT[GHR][address_branch1[9:2]];
                taken_predict1 <= PHT[GHR][address_branch1[9:2]];
            end
        end
    end
    
    //update BTB and get nextPC
    always @(posedge clk)begin
        if(rst)begin
            /*cannot reset memory in one cycle
            for(i = 0; i < 1024; i = i + 1)begin
                valid[i] <= 0;
            end
            */
        end
        else begin
            if(train_valid0)begin
                BTB[address_branch0[11:2]] <= {address_branch0, address_result0};
                valid[address_branch0[11:2]] <= isbranch0;
                if(PC0 == address_branch0)begin
                    nextPC0 <= isbranch0? address_result0 : PC0 + 4;
                end
                else if(PC0 == BTB[PC0[11:2]][63:32]) begin
                    nextPC0 <= valid[PC0[11:2]] ? BTB[PC0[11:2]][31:0] : PC0 + 4;
                end
                else begin
                    nextPC0 <= PC0 + 4;
                end
            end
            else begin
                if(PC0 == BTB[PC0[11:2]][63:32]) begin
                    nextPC0 <= valid[PC0[11:2]] ? BTB[PC0[11:2]][31:0] : PC0 + 4;
                end
                else begin
                    nextPC0 <= PC0 + 4;
                end
            end
            if(train_valid1)begin
                BTB[address_branch1[11:2]] <= {address_branch1, address_result1};
                valid[address_branch1[11:2]] <= isbranch1;
                if(PC1 == address_branch1)begin
                    nextPC1 <= isbranch1? address_result1 : PC1 + 4;
                end
                else if(PC1 == BTB[PC1[11:2]][63:32]) begin
                    nextPC1 <= valid[PC1[11:2]] ? BTB[PC1[11:2]][31:0] : PC1 + 4;
                end
                else begin
                    nextPC1 <= PC1 + 4;
                end
            end
            else begin
                if(PC1 == BTB[PC1[11:2]][63:32]) begin
                    nextPC1 <= valid[PC1[11:2]] ? BTB[PC1[11:2]][31:0] : PC1 + 4;
                end
                else begin
                    nextPC1 <= PC1 + 4;
                end
            end
        end
    end
    
    assign target0 = taken_predict0 ? nextPC0 : PC0 + 4;
    assign target1 = taken_predict1 ? nextPC1 : PC1 + 4;
    
endmodule
