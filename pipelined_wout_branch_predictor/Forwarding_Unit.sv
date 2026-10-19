`timescale 1ns / 1ps

module Forwarding_Unit(

    input  logic clk_i         ,
    input  logic rst_n         ,
    input  logic [4:0] Rs1     ,
    input  logic [4:0] Rs2     ,
    input  logic [4:0] RdMem   ,  
    input  logic [4:0] RdWb    ,
    input  logic       weMEM   ,
    input  logic       weWB    ,
    output logic [1:0] ForwardA,
    output logic [1:0] ForwardB
    
    );
    
    
always_comb begin
    
        if(Rs1==0)          ForwardA = 2'b00;
        else if(weMEM && Rs1!=0  &&  Rs1==RdMem) ForwardA = 2'b01;    
        else if(weWB && Rs1!=0  &&  Rs1==RdWb)  ForwardA = 2'b10;
        else                ForwardA = 2'b00;
        
        if(Rs2==0)          ForwardB = 2'b00;
        else if(weMEM && Rs2!=0  && Rs2==RdMem) ForwardB = 2'b01;                                          
        else if(weWB  && Rs2!=0  &&  Rs2==RdWb)  ForwardB = 2'b10;
        else                ForwardB = 2'b00;       
    
end   
 
endmodule




