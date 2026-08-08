`timescale 1ns / 1ps

module Data_Memory(
    input clk_i,
    input rst_n,
    input we,       //control signal
    input re,       //control signal
    
    input [31:0] a,
    input [31:0] wd,
    output [31:0] rd
    );

 

logic [31:0] data_mem [127:0];
 
 
assign rd = re ? data_mem [a[31:2]] : 0;     

  
    
always_ff@(posedge clk_i) begin

    if(!rst_n) begin
        data_mem  <= '{default: '0} ;
    end
    
    else begin
    
        if(we) begin
            data_mem [a[31:2]] <= $signed(wd) ;
        end
            
    end
           
end     
    
    
    
endmodule
