`timescale 1ns / 1ps

module Program_Counter(
    input clk_i,
    input rst_n,
    input logic [31:0] pc_d,
    output logic [31:0] pc_q
    );
    
always_ff@(posedge clk_i)  begin
    if(!rst_n)   begin                              //synchronus active low reset
        pc_q    <=  32'h00000000;     //pc_q<=32'hbfc00000; for MIPS processor
    
    end
    
    else begin
        pc_q    <=  pc_d;
    end
end  
    
endmodule
