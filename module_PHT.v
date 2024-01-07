`timescale 1ns / 1ps

module module_setofPHT(
    input clk,
    input rst,
    input update,
    input [9:2] BHR,
    input [9:2] branchPC_lower,
    input [9:2] currentPC_lower,
    input taken,
    output taken_predict
    );
    
    reg [1:0] PHT [255:0][255:0];//[1:0] PHT[2^BHR的宽度-1:0][2^PC低位的位数-1:0]
    integer i, j;
    
    always @(posedge clk) begin
        if(rst)begin
            for(i = 0; i < 256; i = i + 1)begin
                for(j = 0; j < 256; j = j + 1)begin
                    PHT[i][j] <= 2'b00;
                end
            end
        end
        else if(update)begin
            if(taken)begin
                if(PHT[BHR][branchPC_lower] != 2'b11)
                    PHT[BHR][branchPC_lower] <= PHT[BHR][branchPC_lower] + 1;
            end
            else begin
                if(PHT[BHR][branchPC_lower] != 2'b00)
                    PHT[BHR][branchPC_lower] <= PHT[BHR][branchPC_lower] - 1;
            end
        end
        else
            ;
    end
    
    assign taken_predict = PHT[1][BHR][currentPC_lower];
    
endmodule
