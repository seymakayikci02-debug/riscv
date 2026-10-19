`timescale 1ns / 1ps

module Program_Counter(
    input clk_i,
    input rst_n,
    input pc_en_n,
    input logic [31:0] pc_d,
    output logic [31:0] pc_q
    );
    
    
    logic pc_en_ff=0;
    logic [31:0] pc_d_ff =0;

    
always_ff@(posedge clk_i)  begin

    if(!rst_n)   begin                              //synchronus active low reset
        pc_q    <=  32'h00000000;     //pc_q<=32'hbfc00000; for MIPS processor
    
    end
 
    else if(pc_en_n) begin      
   
        pc_q    <=  pc_q;    
    end                         
    else  begin
        pc_q     <=  pc_d;
    end
    
    
end  
    
endmodule







