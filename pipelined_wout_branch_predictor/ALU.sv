`timescale 1ns / 1ps

module ALU(
    input   [31:0] a,
    input   [31:0] b,
    input   [4:0]  F,
    output  logic [31:0] y,
    output  logic branch_correct,
    output  logic [3:0] ls_control
    );
    
always_comb begin
    branch_correct =0;
    ls_control=4'b0000;
    case(F) 
    
    5'b00000: y = a & b;                               //it will and bit by bit. doenst matter if its sign
    5'b00001: y = a | b;                               //or  
    5'b00010: y = a ^ b ;                              //xor
    5'b00011: y = ~(a | b);                            //nor
       
    5'b00100: y = $signed(a) + $signed(b);             //add       
    5'b00101: y = $signed(a) - $signed(b);             //substract 
      
    5'b00110: y =($signed(a) < $signed(b)) ? 32'd1 : 32'd0 ;    //slt
    5'b00111: y =(a < b) ? 1 : 0 ;                      //sltu
       
    5'b01000: y = a<<b   ;                      //sll
    5'b01001: y = a>>b   ;                      //srl
    5'b01010: y = a>>>b  ;                      //sra
    
    5'b11100: y = a<<b[4:0]             ;          //slli    
    5'b11101: y = a>>b[4:0]             ;          //srli                               
    5'b11110: y = $signed(a) >>>b[4:0]  ;          //srai
               
    5'b01101: branch_correct = ($signed(a) == $signed(b)) ? 1'b1  : 1'b0 ;        //beq 
    5'b01110: branch_correct = ($signed(a) != $signed(b)) ? 1'b1  : 1'b0 ;        //bne  
    5'b01111: branch_correct = ($signed(a) <  $signed(b)) ? 1'b1  : 1'b0 ;        //blt               
    5'b10000: branch_correct = ($signed(a) >= $signed(b)) ? 1'b1  : 1'b0 ;        //bge
    5'b10001: branch_correct = (        a   <         b ) ? 1'b1  : 1'b0 ;        //bltu
    5'b10010: branch_correct = (        a   >=        b ) ? 1'b1  : 1'b0 ;        //bgeu 
    
    
    5'b10011: begin  y = $signed(a) + $signed(b);       ls_control=4'b0000;    end         //lb        
    5'b10100: begin  y = $signed(a) + $signed(b);       ls_control=4'b0001;    end         //lh       
    5'b10110: begin  y = $signed(a) + $signed(b);       ls_control=4'b0010;    end         //lw           
    5'b10111: begin  y = $signed(a) + $signed(b);       ls_control=4'b0011;    end         //lbu       
    5'b11000: begin  y = $signed(a) + $signed(b);       ls_control=4'b0100;    end         //lhu   
                                                                              
    5'b11001: begin  y = $signed(a) + $signed(b);       ls_control=4'b0101;    end          //sb       
    5'b11010: begin  y = $signed(a) + $signed(b);       ls_control=4'b0110;    end          //sh     
    5'b11011: begin  y = $signed(a) + $signed(b);       ls_control=4'b0111;    end          //sw 
    5'b01011: begin  y = b;                                                    end          //lui 
    5'b01100: begin  y = a + 4;                                                end          //jal,jalr                      
                          
                                       
    default : y=0 ;
    
    endcase
    end   
    
endmodule
