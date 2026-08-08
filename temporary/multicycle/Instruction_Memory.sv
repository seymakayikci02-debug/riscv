`timescale 1ns / 1ps

module Instruction_Memory(
    input [4:0] a,     //instruction address input
    output [31:0] rd
    );
 
logic [31:0] ROM [31:0];   
    
initial begin       //executes one time 
    $readmemh("battery_sensor_mem.mem",ROM); 
end   
       
assign rd=ROM[a];
       
endmodule
