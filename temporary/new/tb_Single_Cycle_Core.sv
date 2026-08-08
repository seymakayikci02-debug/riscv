`timescale 1ns / 1ps


module tb_Single_Cycle_Core(

    );
    
    logic   clk_i  ;
    logic   rst_n  ;
    
    
    
    
  Single_Cycle_Core dut(
    .clk_i  (clk_i)  ,
    .rst_n  (rst_n)  
    );  


always #10 clk_i=~clk_i; 


initial begin
    clk_i=0;
    rst_n =0;
    #100;
    rst_n = 1;
    



end


    
endmodule
