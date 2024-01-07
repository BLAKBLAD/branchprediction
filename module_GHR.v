`timescale 1ns / 1ps

module module_GHR(
    input clk,
    input rst,
    input update,
    input taken,
    output [7:0] GHR
    );
    
    reg [7:0] BHR;
    
    always @(posedge clk) begin
        if(rst)
            BHR <= 8'd0;
        else begin
            if(update) begin
                if(taken)
                    BHR <= (BHR << 1) + 1;
                else
                    BHR <= BHR << 1;
            end
            else
                ;
        end
    end
    
    assign GHR = BHR;
    
endmodule
