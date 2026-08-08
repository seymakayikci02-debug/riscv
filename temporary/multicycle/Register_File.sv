`timescale 1ns / 1ps

module Register_File(
    input clk_i,
    input rst_n,
    input we3,          //control signal
    
    input [4:0] ra1,     //read address
    input [4:0] ra2,     //
    input [4:0] wa3,     //write address
    input  [31:0] wd3,  //write data    

    output [31:0] rd1,      //read data
    output [31:0] rd2
    
    );
    
logic [31:0] reg_file [31:0];
 
 
assign rd1 = ra1==0 ? 0 : reg_file [ra1];      //0. register is hard coded to 0. 
assign rd2 = ra2==0 ? 0 : reg_file [ra2]; 
  
    
always_ff@(posedge clk_i) begin

    if(!rst_n) begin
        reg_file  <= '{default: '0} ;
    end
    
    else begin
    
        if(we3 && wa3!=0 ) begin
            reg_file [wa3] <= $signed(wd3) ;
        end
            
    end
           
end    
    
    
endmodule
