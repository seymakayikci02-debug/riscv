`timescale 1ns / 1ps

module Imm_Gen(
    input [31:0] instr,
    output logic [31:0] extended_imm

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

     
always_comb begin

case(instr[6:0])

    //R_format                :  extended_imm = { {19{instr[31]}} , instr[31] , instr[7] , instr[30:25] , instr[11:8] , 1'b0};            
    //I_load_format           :  extended_imm = (instr[15:12]== 3'b100 || instr[15:12]== 3'b101 ) ? { {20{1'b0}} , instr[31:20] } : { {20{instr[31]}} , instr[31:20] }  ;   
    I_load_format           :  extended_imm = { {20{instr[31]}} , instr[31:20] };          
    I_arithmetic_format     :  extended_imm = { {20{instr[31]}} , instr[31:20] };       
    I_jump_format           :  extended_imm = { {20{instr[31]}} , instr[31:20] };               
    S_format                :  extended_imm = { {19{instr[31]}} , instr[31:25] , instr[11:7] };                     
    B_format                :  extended_imm = { {19{instr[31]}} , instr[31] , instr[7] , instr[30:25] , instr[11:8] , 1'b0}    ;               
    J_format                :  extended_imm = { {11{instr[31]}} , instr[31] , instr[19:12] , instr[20] , instr[30:21] , 1'b0 } ;               
    U_load_format           :  extended_imm = {  instr[31:12] , {12{1'b0}}};             
    U_add_format            :  extended_imm = {  instr[31:12] , {12{1'b0}}};       
    endcase

// if(instr[6:0]==R_format)       extended_imm = { {19{instr[31]}} , instr[31] , instr[7] , instr[30:25] , instr[11:8] , 1'b0};
// 
// else if (instr[6:0]==I_load_format) extended_imm = { {11{instr[31]}} , instr[31] , instr[19:12] , instr[20] , instr[30:21] , 1'b0 };    
//                 
// else if (instr[6:0]==I_arithmetic_format) extended_imm = { {11{instr[31]}} , instr[31] , instr[19:12] , instr[20] , instr[30:21] , 1'b0 };  
// 
// else if (instr[6:0]==I_jump_format) extended_imm = { {11{instr[31]}} , instr[31] , instr[19:12] , instr[20] , instr[30:21] , 1'b0 };  
// 
// else if (instr[6:0]==1101111) extended_imm = { {11{instr[31]}} , instr[31] , instr[19:12] , instr[20] , instr[30:21] , 1'b0 };  
// 
// else if (instr[6:0]==1101111) extended_imm = { {11{instr[31]}} , instr[31] , instr[19:12] , instr[20] , instr[30:21] , 1'b0 };  

end    
    

    
    
endmodule
