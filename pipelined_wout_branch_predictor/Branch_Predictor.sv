`timescale 1ns / 1ps

module Branch_Predictor(
    input logic clk_i,
    input logic rst_n,
    input logic taken,
    output logic [1:0] BranchPredictionBuffer,
    input logic branch_came,
    output logic flush,   
    output logic stall
    );
   
    
typedef enum logic [2:0]{
                      IDLE            =3'b000,
                      PredictTaken1   =3'b001,  
                      PredictTaken2   =3'b010,
                      PredictNotTaken1=3'b011,
                      PredictNotTaken2=3'b100
                      }state_t;    
    
state_t state,next_state; 

 
 
    
    
    
always_comb begin
    case(state) 
    IDLE            :begin
     BranchPredictionBuffer=2'd0;
     flush=0;
     next_state=PredictTaken1;
    end          
    
    
    PredictTaken1   : begin
        BranchPredictionBuffer=2'd0;   
        if(taken ) begin   //if(taken && branch_came) 
            // After taking taken signal we need to release stall 
            // Since we initially stalled pipeline
            flush=0;     
            next_state=PredictTaken1;                
        end
            
        else  if (!taken ) begin   //else  if (!taken && branch_came) 
            // After taking not taken signal we need to release stall        
            // Since we initially stalled pipeline and also control signals should be flushed.                       
            flush=1;
            next_state=PredictTaken2;
        end
            
        else begin
            // initially when we predict taken for the first time 
            // we need to stall for one clock cycle   
            flush=0;                                        
            next_state=PredictTaken1;                       
        end
          
    end

   
    PredictTaken2   :begin
        BranchPredictionBuffer=2'd1;
        if(taken ) begin      //if(taken && branch_came)
            // After taking taken signal we need to release stall 
            // Since we initially stalled pipeline
            flush=0;
            next_state=PredictTaken1;
        end
        
        else if(!taken ) begin        //else if(!taken && branch_came)
            // After taking not taken signal we need to release stall        
            // Since we initially stalled pipeline and also control signals should be flushed.
            flush=1;
            next_state=PredictNotTaken1;
        end
        
        else begin 
            // initially when we predict taken for the first time 
            // we need to stall for one clock cycle   
            flush=0;
            next_state=PredictTaken2;
        end    
    end
   
    PredictNotTaken1:begin
        BranchPredictionBuffer=2'd2;
        if(taken ) begin
            // After taking taken signal we need to stall the pipeline
            // And also we need to fluch the pipeline since we predict uncorrectly       
            flush=1;
            next_state=PredictTaken2;
        end
        else if(!taken ) begin 
            // After taking not taken signal                         
            // we can continue without stalling or flushing         
            flush=0;                                  
            next_state=PredictNotTaken2;   
        end                             
        
        else  begin 
            // initially when we predict not taken for the first time 
            // we dont need to stall for one clock cycle 
            flush=0;
            next_state=PredictNotTaken1;
        end
    end
   
    PredictNotTaken2:begin
        BranchPredictionBuffer=2'd3;
        if(taken ) begin    
            // After taking taken signal we need to stall the pipeline                 
            // And also we need to fluch the pipeline since we predict uncorrectly         
            flush=1;                                                    
            next_state=PredictNotTaken1;         
        end                                   
        else if(!taken ) begin  
            // After taking not taken signal                  
            // we can continue without stalling or flushing   
            flush=0;                                                  
            next_state=PredictNotTaken2;      
        end                                   
                                              
        else  begin       
            // initially when we predict not taken for the first time
            // we dont need to stall for one clock cycle                             
            flush=0;                                                   
            next_state=PredictNotTaken2;      
        end                                                                           
    end
    
    default: begin
        flush=0;
    
    end
    endcase

end    
    
    
always_comb begin
if(!rst_n) begin
        stall=0;
    
    end

    else begin
        if (branch_came)    stall=1;    
        else                stall=0;
    end

end    
    
    
always_ff@(posedge clk_i)  begin

    if(!rst_n) begin
        state<=IDLE;
    
    end

    else begin
        // if (branch_came) begin  stall=1; state<=next_state;      end
        // else             begin  stall=0;     state <= state;        end
        if (branch_came)    state<=next_state;    
        
    end


end  
      
    
    
endmodule



