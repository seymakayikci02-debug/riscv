`timescale 1ns / 1ps

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


module Control_Unit(
    input opcode_t opcode,
    output logic Branch,
    output logic MemRead,
    output logic MemtoReg,
    output logic [3:0] ALUOp,
    output logic MemWrite,
    output logic ALUSrc,
    output logic RegWrite,
    output logic Jump,
    output logic [1:0] RegWriteControl
    );
 

 

    
always_comb   begin

    case(opcode)

    R_format :   begin
        Branch          =1'b0        ;
        MemRead         =1'b0        ;
        MemtoReg        =1'b0        ;
        ALUOp           =4'b0000     ;
        MemWrite        =1'b0        ;
        ALUSrc          =1'b0        ;
        RegWrite        =1'b1        ;
        Jump            =1'b0        ;
        RegWriteControl =2'b00       ;
    end        
    
          
    I_load_format  :   begin
    
        Branch      =1'b0           ; 
        MemRead     =1'b1           ; 
        MemtoReg    =1'b1           ; 
        ALUOp       =4'b0001        ; 
        MemWrite    =1'b0           ; 
        ALUSrc      =1'b1           ; 
        RegWrite    =1'b1           ; 
        Jump        =1'b0           ;
        RegWriteControl =2'b00      ;
    end        
    
        
    I_arithmetic_format   : begin
    
        Branch      =1'b0           ; 
        MemRead     =1'b0           ; 
        MemtoReg    =1'b0           ; 
        ALUOp       =4'b0010        ; 
        MemWrite    =1'b0           ; 
        ALUSrc      =1'b1           ; 
        RegWrite    =1'b1           ; 
        Jump        =1'b0           ;
        RegWriteControl =2'b00      ;
    end        
    
    
    I_jump_format  : begin      //jalr
    
        Branch      =1'b0           ; 
        MemRead     =1'b0           ; 
        MemtoReg    =1'b0           ; 
        ALUOp       =4'b0011        ; 
        MemWrite    =1'b0           ; 
        ALUSrc      =1'b1           ; 
        RegWrite    =1'b1           ; 
        Jump        =1'b1           ;
        RegWriteControl =2'b01      ;
    end        
    
           
    S_format   :  begin
    
        Branch      =1'b0           ; 
        MemRead     =1'b0           ; 
        MemtoReg    =1'bx           ; 
        ALUOp       =4'b0100        ; 
        MemWrite    =1'b1           ; 
        ALUSrc      =1'b1           ; 
        RegWrite    =1'b0           ; 
        Jump        =1'b0           ;
        RegWriteControl =2'bxx      ;
        
    end        
    
              
    B_format  :     begin
    
        Branch      =1'b1           ; 
        MemRead     =1'b0           ; 
        MemtoReg    =1'b0           ; 
        ALUOp       =4'b0101        ; 
        MemWrite    =1'b0           ; 
        ALUSrc      =1'b0           ; 
        RegWrite    =1'b0           ; 
        Jump        =1'b0           ;
        RegWriteControl =2'bxx      ;
    end        
    
            
    J_format  :    begin    //jal
    
        Branch      =1'b0           ; 
        MemRead     =1'b0           ; 
        MemtoReg    =1'b0           ; 
        ALUOp       =4'b0110        ; 
        MemWrite    =1'b0           ; 
        ALUSrc      =1'b0           ; 
        RegWrite    =1'b1           ; 
        Jump        =1'b1           ;
        RegWriteControl =2'b01      ;
    end        
    
            
    U_load_format:   begin      //lui
    
        Branch      =1'bx           ; 
        MemRead     =1'bx           ; 
        MemtoReg    =1'bx           ; 
        ALUOp       =4'b0111        ; 
        MemWrite    =1'bx           ; 
        ALUSrc      =1'bx           ; 
        RegWrite    =1'b1           ; 
        Jump        =1'bx           ;
        RegWriteControl =2'b10      ;
    
    end        
    
          
    U_add_format   :   begin    //auipc
    
        Branch      =1'bx           ; 
        MemRead     =1'bx           ; 
        MemtoReg    =1'bx           ; 
        ALUOp       =4'b1000        ; 
        MemWrite    =1'bx           ; 
        ALUSrc      =1'bx           ; 
        RegWrite    =1'b1           ; 
        Jump        =1'bx           ;
        RegWriteControl =2'b11      ;
    
    end            
  

    endcase




end


    
endmodule





