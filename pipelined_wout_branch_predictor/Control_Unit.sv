`timescale 1ns / 1ps

module Control_Unit(
    input   logic clk_i            ,
    input   logic rst_n            ,
    input   logic [6:0] opcode     ,
    input   logic [2:0] funct3     , 
    input   logic [6:0] funct7     , 
    input   logic Branch           ,  
    output  logic  AluSrcA         ,
    output  logic  AluSrcB         ,
    output  logic [4:0] ALUControl ,         //F
    output  logic RegWrite         ,
    output  logic MemWrite         ,
    output  logic MemRead          ,    
    output  logic [1:0] ResultSrc            
    );
   

 typedef enum logic [6:0] {
                R_format            =7'b0110011,
                I_load_format       =7'b0000011,
                I_arithmetic_format =7'b0010011,
                I_jump_format       =7'b1100111,
                S_format            =7'b0100011,
                B_format            =7'b1100011,
                J_format            =7'b1101111,
                U_load_format       =7'b0110111,
                U_add_format        =7'b0010111,
                bubble              =7'b0000000
                }opcode_t;  



logic  [3:0] ALUOp  ;


ALU_Control_Unit alu_ctrl_unit(
    . funct3  (funct3 )  ,
    . funct7  (funct7 )  ,
    . ALUOp   (ALUOp  )  ,    //4 bit
    . F       (ALUControl)    //5 bit
    );
   
   
always_comb   begin

    case(opcode)
    bubble   :  begin
    ALUOp       =4'b0000 ;    
    RegWrite    =1'b0    ;    
    MemWrite    =1'b0    ;    
    MemRead     =1'b0    ;    
    ResultSrc   =1'b0    ;    
    AluSrcA     =1'b0    ;    
    AluSrcB     =1'b0    ;     
    end 
    
    
    R_format :   begin
        ALUOp       =4'b0000 ;        
        RegWrite    =1'b1    ;
        MemWrite    =1'b0    ;
        MemRead     =1'b0    ;
        ResultSrc   =1'b0    ;
        AluSrcA     =1'b1    ;
        AluSrcB     =1'b1    ;      
    end        
    
          
    I_load_format  :   begin
    
        ALUOp       =4'b0001 ;  
        RegWrite    =1'b1    ;  
        MemWrite    =1'b0    ;  
        MemRead     =1'b1    ;  
        ResultSrc   =1'b1    ; 
        AluSrcA     =1'b1    ;
        AluSrcB     =1'b0    ;  
                                       
    end        
    
        
    I_arithmetic_format   : begin
    
        ALUOp       =4'b0010 ;  
        RegWrite    =1'b1    ;  
        MemWrite    =1'b0    ;  
        MemRead     =1'b0    ;  
        ResultSrc   =1'b0    ; 
        AluSrcA     =1'b1    ; 
        AluSrcB     =1'b0    ;  
                                    
    end        
    
    
    
     S_format   :  begin            
                                
         ALUOp=4'b0100 ;            
         RegWrite    =1'b0   ;     
         MemWrite    =1'b1   ;     
         MemRead     =1'b0   ;     
         ResultSrc   =1'b0   ;    
         AluSrcA     =1'b1   ;                           
         AluSrcB     =1'b0   ;                                 
     end                            
     
     U_load_format:   begin      //lui

          ALUOp       =4'b0111 ;            
          RegWrite    =1'b1    ;     
          MemWrite    =1'b0    ;     
          MemRead     =1'b0    ;     
          ResultSrc   =1'b0    ;    
          AluSrcA     =1'b1    ;                           
          AluSrcB     =1'b0    ;          
     end   
     
     
     U_add_format   :   begin    //auipc
    
          ALUOp       =4'b1000 ;            
          RegWrite    =1'b1    ;     
          MemWrite    =1'b0    ;     
          MemRead     =1'b0    ;     
          ResultSrc   =1'b0    ;    
          AluSrcA     =1'b0    ;                           
          AluSrcB     =1'b0   ;  
      end 
     
     
     I_jump_format  : begin      //jalr
 
          ALUOp       =4'b0011 ;
          RegWrite    =1'b1    ;
          MemWrite    =1'b0    ;
          MemRead     =1'b0    ;
          ResultSrc   =1'b0    ;
          AluSrcA     =1'b0    ;                      
          AluSrcB     =1'b0   ;
         
     end   
     
     
     J_format  :    begin    //jal          
     
         ALUOp       =4'b0110 ;              
         RegWrite    =1'b1    ;    
         MemWrite    =1'b0    ;    
         MemRead     =1'b0    ;    
         ResultSrc   =1'b0    ;    
         AluSrcA     =1'b0    ;    
         AluSrcB     =1'b0    ;     
          
     end                                    
     
     B_format  :     begin           
                                       
         ALUOp       =4'b0101  ;   
         RegWrite    =1'b0    ;   
         MemWrite    =1'b0    ;   
         MemRead     =1'b0    ;   
         ResultSrc   =1'b0    ;   
         AluSrcA     =1'b1    ;   
         AluSrcB     =1'b1    ;                                     
     end                               
     
      default: begin
      
        AluSrcA     =0 ;               
        AluSrcB     =0 ;       
        ALUControl  =0 ;                 
        RegWrite    =0 ;                 
        MemWrite    =0 ;                 
        MemRead     =0 ;                 
        ResultSrc   =0 ;           
    
      end
    
    endcase
    end
endmodule

