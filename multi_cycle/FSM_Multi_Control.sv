`timescale 1ns / 1ps

module FSM_Multi_Control(
    input   logic clk_i               ,
    input   logic rst_n               ,
    input   logic [6:0] opcode        ,
    input   logic [2:0] funct3        , 
    input   logic [6:0] funct7        , 
    input   logic Branch              ,  
    output  logic [1:0] AluSrcA       ,
    output  logic [1:0] AluSrcB       ,
    output  logic [4:0] ALUControl    ,         //F
    output  logic IRWrite             ,
    output  logic PCWrite             ,
    output  logic RegWrite            ,
    output  logic MemWrite            ,
    output  logic MemRead             ,    
    output  logic [1:0] ResultSrc            
    );
   

 typedef enum logic [6:0] {
                R_format                =7'b0110011,
                I_load_format           =7'b0000011,
                I_arithmetic_format     =7'b0010011,
                I_jump_format           =7'b1100111,
                S_format                =7'b0100011,
                B_format                =7'b1100011,
                J_format                =7'b1101111,
                U_load_format           =7'b0110111,
                U_add_format            =7'b0010111
                }opcode_t;  
  
typedef enum logic [3:0] {
                S0 =4'b0000,
                S1 =4'b0001,
                S2 =4'b0010,
                S3 =4'b0011,
                S4 =4'b0100,
                S5 =4'b0101,
                S6 =4'b0110,
                S7 =4'b0111,
                S8 =4'b1000,
                S9 =4'b1001,
                S10=4'b1010,
                S11=4'b1011,
                S12=4'b1100
                }state_t;
    
state_t state       ;
state_t next_state  ;
logic  [3:0] ALUOp  ;


ALU_Control_Unit alu_ctrl_unit(
    . funct3  (funct3 )  ,
    . funct7  (funct7 )  ,
    . ALUOp   (ALUOp  )  ,    //4 bit
    . F       (ALUControl)         //5 bit
    );

    
always_comb begin

    
    
    case (state)
    S0: begin                                   //FETCH   
        RegWrite   =1'b0   ;
        MemWrite   =1'b0   ;
        MemRead    =1'b0   ;
           
        ResultSrc  =2'b10  ;
        AluSrcA    =2'b00  ;
        AluSrcB    =2'b10  ;
        ALUOp      =4'b1000;    
        IRWrite    =1'b1   ;
        PCWrite    =1'b1   ;
        next_state =S1     ;  
    end
    
    S1: begin                                   //DECODE   
        ResultSrc  =2'b00   ; 
        IRWrite    =1'b0    ;           //for jal and auipc
        AluSrcA    =2'b01    ;
        AluSrcB    =2'b01   ;
        PCWrite    =1'b0    ;
        ALUOp      =4'b1000   ;
        case(opcode)
        R_format               :    next_state=S6;                 
        I_load_format          :    next_state=S2;             
        I_arithmetic_format    :    next_state=S8;          
        I_jump_format          :    begin  next_state=S11;  AluSrcA    =2'b11    ;      end         
        S_format               :    next_state=S2;                
        B_format               :    next_state=S10;              
        J_format               :    next_state=S9;                
        U_load_format          :    next_state=S12;               
        U_add_format           :    begin  next_state=S7;   ALUOp      =4'b0111   ;     end
        endcase
    end
    
    S2: begin                                   //MEMADR(EXECUTE)    
        AluSrcA    =2'b10     ; 
        AluSrcB    =2'b01     ; 
        PCWrite    =1'b0      ;         
        case(opcode)                
        I_load_format          :    begin next_state=S3 ; ALUOp=4'b0001 ; end                               
        S_format               :    begin next_state=S5 ; ALUOp=4'b0100 ; end                             
        endcase           
    end
    
    S3: begin                                   //MEMREAD
        ResultSrc  =2'b00 ;
        MemRead    =1'b1  ;
        PCWrite    =1'b0  ;
        next_state =S4    ;
    end
   
    S4: begin                                   //MEMWB     
        ResultSrc   =2'b01 ;            
        RegWrite    =1'b1  ;
        MemRead     =1'b0  ;
        PCWrite     =1'b0  ;
        next_state  =S0    ;
    end
    
    S5: begin                                   //MEM_WRITE
        ResultSrc  =2'b00  ;
        MemWrite   =1'b1   ;  
        PCWrite    =1'b0   ;
        next_state =S0     ;        
    end
    
    S6: begin                                     //EXECUTE_R 
        AluSrcA    =2'b10   ; 
        AluSrcB    =2'b00   ; 
        PCWrite    =1'b0    ;
        ALUOp      =4'b0000 ;
        next_state =S7      ;                                        
    end                                          
                                                 
    S7: begin                      //ALU_WRITE_BACK               
        PCWrite    =1'b0        ; 
        ResultSrc  =2'b00       ;       
        RegWrite    =1'b1 ;             
        next_state =S0    ;     
                                    
    end
    
    S8: begin                                      //EXECUTE_L     
        AluSrcA    =2'b10   ;
        AluSrcB    =2'b01   ;
        PCWrite    =1'b0    ;
        ALUOp      =4'b0010 ;  
        next_state =S7      ;                        
    end
    
    S9: begin                                      //EXECUTE_JAL
        AluSrcA    =2'b01   ;
        AluSrcB    =2'b10   ;
        PCWrite    =1'b1    ;
        ALUOp      =4'b0110 ;
        next_state =S7      ;
    end
    
    S10: begin                                      //EXECUTE_B
        AluSrcA    =2'b10    ;
        AluSrcB    =2'b00    ;
        
        ALUOp      =4'b0101   ;
        if(Branch) begin
            ResultSrc   =2'b00;
            PCWrite     =1'b1 ;
        end
        next_state =S0       ;
    end
    
    S11: begin                                  //EXECUTE_JALR
        AluSrcA    =2'b01   ;
        AluSrcB    =2'b10   ;
        ResultSrc  =2'b00   ;
        PCWrite    =1'b1    ;              
        ALUOp      =4'b0110 ;
        next_state =S7      ;   
    end
    
    
    S12: begin                                  //IMM_WRITE_BACK lui
        ResultSrc  =2'b11  ;
        AluSrcA    =2'b01  ;
        AluSrcB    =2'b01  ;
        PCWrite    =1'b0   ;
        RegWrite   =1'b1 ; 
        next_state =S0     ;
    end
    endcase
end    


always_ff@(posedge clk_i) begin
    if(!rst_n) begin
        state<=S0;
    end
    else begin
        state<=next_state;
    end   
end

endmodule



