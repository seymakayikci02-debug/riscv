`timescale 1ns / 1ps

module Hazard_Detection_Unit(
    input logic clk_i,
    input logic rst_n,
    input logic BranchCorrect,
    input logic [6:0] opcode,
    input logic [3:0] RdEx,
    input logic [3:0] Rs1 ,
    input logic [3:0] Rs2 ,
    output logic [1:0] TargetBaseSel,
    output logic PCAddrSel,
    output logic flush_de,
    output logic flush_ex,
    output logic stall_fe,
    output logic stall_de
    );

logic BranchCame            ;
logic Taken                 ;
logic BranchPredictionBuffer;
logic AssumeTaken           ;
logic JalrCame              ;
logic JalCame               ;
logic BranchCameIN          ;
logic LoadCame               ;


assign BranchCame = (opcode==7'b1100011) ? 1'b1 : 1'b0 ;
assign JalrCame   = (opcode==7'b1100111) ? 1'b1 : 1'b0 ;
assign JalCame    = (opcode==7'b1101111) ? 1'b1 : 1'b0 ;
assign LoadCame   = (opcode==7'b0000011) ? 1'b1 : 1'b0 ;


always_comb begin
    BranchCameIN =1'b0;    
    if(BranchCorrect)  begin 
        TargetBaseSel=2'b10;    
        PCAddrSel    =1'b1;     
        flush_de     =1'b1;
        flush_ex     =1'b1;
        stall_fe     =1'b0;
        stall_de     =1'b0;
       
       
    end
                                      
    else if(JalCame)  begin 
        flush_de     =1'b1; 
        flush_ex     =1'b1;
        TargetBaseSel=2'b01;     
        PCAddrSel    =1'b1;      
    end
    
    else if(JalrCame)  begin 
        flush_de     =1'b1;  
        flush_ex     =1'b1;
        TargetBaseSel=2'b00;     
        PCAddrSel    =1'b1;      
    end
    
    else if(LoadCame)  begin 
        if(RdEx==Rs1 || RdEx==Rs2 ) begin
            TargetBaseSel=2'bx;
            PCAddrSel    =1'b0;
            flush_de     =1'b0;
            flush_ex     =1'b1;
            stall_fe     =1'b1;
            stall_de     =1'b1;
        end
        
        else begin
            TargetBaseSel=2'bx;
            PCAddrSel    =1'b0;
            flush_de     =1'b0;
            flush_ex     =1'b0;
            stall_fe     =1'b0;
            stall_de     =1'b0;
        end
       
    end                      
  
    else begin 
        TargetBaseSel=2'bx;  
        PCAddrSel    =1'b0;  
        flush_de     =1'b0;
        flush_ex     =1'b0;
        stall_fe     =1'b0;
        stall_de     =1'b0;
         
    end
end    
      
endmodule
 






