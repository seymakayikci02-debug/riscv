`timescale 1ns / 1ps


module Mux(
    input  sel,
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] c
    );
    
    assign c = sel ? $signed(a) : $signed(b) ;
    
endmodule
