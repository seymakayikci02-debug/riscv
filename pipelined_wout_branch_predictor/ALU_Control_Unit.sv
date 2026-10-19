`timescale 1ns / 1ps


module ALU_Control_Unit(
    input   [2:0] funct3,
    input   [6:0] funct7,
    input   logic [3:0] ALUOp,
    output  logic [4:0] F
    );
    
    always_comb begin
    
    case(ALUOp)
    
    //R format
    4'b0000: begin         
        if(funct7==7'b0000000 && funct3==3'b111)      F=5'b00000;    //and.
        
        else if(funct7==7'b0000000 && funct3==3'b110) F=5'b00001;   //or.
        
        else if(funct7==7'b0000000 && funct3==3'b100) F=5'b00010;   //xor.

        //else if(funct7==7'bxxxxxxx && funct3==3'bxxx) F=xxxx;   //nor
        
        else if(funct7==7'b0000000 && funct3==3'b000) F=5'b00100;   //add  .
                                                                       
        else if(funct7==7'b0100000 && funct3==3'b000) F=5'b00101;   //substract.
                                                                       
        else if(funct7==7'b0000000 && funct3==3'b010) F=5'b00110;   //slt   .
                                                                       
        else if(funct7==7'b0000000 && funct3==3'b011) F=5'b00111;   //sltu     .                                                                 
                                                                                                 
        else if(funct7==7'b0000000 && funct3==3'b001) F=5'b01000;   //sll    .                        
                                                                                                 
        else if(funct7==7'b0000000 && funct3==3'b101) F=5'b01001;   //srl     .                 
                                                                                                 
        else if(funct7==7'b0100000 && funct3==3'b101) F=5'b01010;   //sra   .                                                                   

    end
    
    //I load format                                                              
    4'b0001: begin                                                             
       if(funct3==3'b000)      F=5'b10011;    //lb                             
                                                                               
       else if(funct3==3'b001) F=5'b10100;    //lh                             
                                                                               
       else if(funct3==3'b010) F=5'b10110;    //lw                             
                                                                                 
       else if(funct3==3'b100) F=5'b10111;    //lbu                              
      
       else if(funct3==3'b101) F=5'b11000;    //lhu   
    end
    
    //I arithmetic format
    4'b0010: begin
        if(funct3==3'b111)      F=5'b00000;    //andi .        
                                                                               
        else if(funct3==3'b110) F=5'b00001;   //ori .           
                                                                                
        else if(funct3==3'b100) F=5'b00010;   //xori .          
                                                                                
        //else if(funct3==3'bxxx) F=xxxx;   //nor         
      
        else if(funct3==3'b000) F=5'b00100;   //addi .          
      
        //else if(funct3==3'b000) F=00000;   //substract    
      
        else if(funct3==3'b010) F=5'b00110;   //slti .          
      
        else if(funct3==3'b011) F=5'b00111;   //sltiu      .   
      
        else if(funct7==7'b0000000 && funct3==3'b001) F=5'b11100;   //slli  .     old value:  F=5'b01011
     
        else if(funct7==7'b0000000 && funct3==3'b101) F=5'b11101;   //srli  .  old value:  F=5'b01100
     
        else if(funct7==7'b0100000 && funct3==3'b101) F=5'b11110;   //srai  .
  
    end
        
    //I jump format
    4'b0011:  F=5'b01100;    //jalr   //PC + 4 
     
    //J format 
    4'b0110:   F=5'b01100;   //jal    //PC + 4 
                                                                     
    //S format                                                       
    4'b0100:  begin                                                  
                                                                     
    if(funct3==3'b000)      F=5'b11001;  //sb
                                                                     
    else if(funct3==3'b001) F=5'b11010;  //sh                        
                                                                     
    else if(funct3==3'b010) F=5'b11011;  //sw
  
    end
   
    //B format
    4'b0101: begin
        if(funct3==3'b000)      F=5'b01101;    //beq  
             
        else if(funct3==3'b001) F=5'b01110;   //bne 
        
        else if(funct3==3'b100) F=5'b01111;   //blt          
                                                           
        else if(funct3==3'b101) F=5'b10000;   //bge                                                                     
                                                           
        else if(funct3==3'b110) F=5'b10001;   //bltu         
                                                           
        else if(funct3==3'b111) F=5'b10010;   //bgeu        
  
    end
  
    //U load format
    4'b0111:   F=5'b01011;     //lui
    //U add format
    4'b1000:   F=5'b00100;     //auipc  

    default: F=0;                   
    
    endcase
    
    end
    
endmodule
