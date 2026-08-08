`timescale 1ns / 1ps


module Add(
    input  [31:0] a,  
    input  [31:0] b,  
    output [31:0] sum 
    );
    
    assign sum = $signed(a) + $signed(b) ;
    
endmodule
