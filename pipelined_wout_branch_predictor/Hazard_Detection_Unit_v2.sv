`timescale 1ns / 1ps

module Hazard_Detection_Unit_v2(
    input logic clk_i,
    input logic rst_n,
    input logic BranchCorrect,
    input logic [6:0] opcode,
    output logic TargetBaseSel,
    output logic PCAddrSel,
    output logic flush,
    output logic stall

    );

logic BranchCame;
logic Taken;
logic BranchPredictionBuffer;
logic AssumeTaken;
logic JalrCame   ;
logic JalCame    ;



Branch_Predictor branch_predictor(
    .clk_i                  (clk_i                 ),
    .rst_n                  (rst_n                 ),
    .taken                  (Taken                 ),
    .BranchPredictionBuffer (BranchPredictionBuffer),
    .branch_came            (BranchCame            ),
    .flush                  (flush                 ),
    .stall                  (stall                 )
    
    );    



 
assign Taken      = BranchCorrect;
assign BranchCame = (opcode==7'b1100011) ? 1'b1 : 1'b0 ;
assign JalrCame   = (opcode==7'b1100111) ? 1'b1 : 1'b0 ;
assign JalCame    = (opcode==7'b1101111) ? 1'b1 : 1'b0 ;
//assign PCAddrSel     = BranchCame==0 ? 1'b0 : (stall ?  !(AssumeTaken) : AssumeTaken) ;
 
always_comb begin
    if(BranchCame ) begin
        case(BranchPredictionBuffer)
        2'd0: AssumeTaken=1;        
        2'd1: AssumeTaken=1;       
        2'd2: AssumeTaken=0;        
        2'd3: AssumeTaken=0;       
        endcase       
    end
                                             
    else begin
        AssumeTaken=0;
    end 
    
    if(AssumeTaken && BranchCame)  begin 
        TargetBaseSel=1'b1;     
        PCAddrSel=1'b1;      
    end
    
    else if(!AssumeTaken && BranchCame)  begin   
        TargetBaseSel=1'bx;                
        PCAddrSel=1'b0;                    
    end                                    
     
    else if(JalCame)  begin 
        stall=1'b1; 
        TargetBaseSel=1'b1;     
        PCAddrSel=1'b1;      
    end
    
    else if(JalrCame)  begin 
        stall=1'b1; 
        TargetBaseSel=1'b0;     
        PCAddrSel=1'b1;      
    end
    else begin 
        if(BranchPredictionBuffer==2'd0 || BranchPredictionBuffer==2'd1) TargetBaseSel=1'b1;
        else if(BranchPredictionBuffer==2'd2 || BranchPredictionBuffer==2'd3) TargetBaseSel=1'b0;
        stall=1'b0; 
        PCAddrSel=1'b0;      
    end
end    
      
endmodule