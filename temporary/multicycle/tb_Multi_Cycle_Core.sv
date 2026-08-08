`timescale 1ns / 1ps

module tb_Multi_Cycle_Core(

    );
    
    logic   clk_i  ;
    logic   rst_n  ;
    
Multi_Cycle_Core dut(
  .clk_i  (clk_i)  ,
  .rst_n  (rst_n)  
  );  


always #10 clk_i=~clk_i; 


initial begin
    clk_i=0;
    rst_n =0;
    #100;
    
    // Input packet:
    //   byte  0: signed temperature = -20
    //   byte  1: unsigned status    = 0xA5
    //   half  2: signed current     = -300
    //   word  4: voltage            = 28000
    
    
    dut.data_mem.data_mem[0][7 :0]=8'hec;
    dut.data_mem.data_mem[0][15:8]=8'hA5;
    dut.data_mem.data_mem[0][31:16]=16'hFED4;
    dut.data_mem.data_mem[1]=32'd28000;
    #10;
    rst_n = 1;
    



end   
    
endmodule
