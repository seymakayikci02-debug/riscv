`timescale 1ns / 1ps

module Single_Cycle_Core(
    input   clk_i,
    input   rst_n
    );


logic [31:0] pc_d           ;
logic [31:0] pc_q           ;
logic [31:0] Instr          ;
logic [31:0] SrcA           ;
logic [31:0] SrcB           ;             
logic [31:0] ALUResult      ;               
logic [31:0] ReadData       ; 
logic [31:0] ExtImm         ;
logic [31:0] ExtImm_shifted ;
logic [31:0] SrcBMuxOut     ;
logic [31:0] Data           ;
logic [31:0] PCBranch       ;
logic [31:0] PCPlus4        ;



//control signals//

logic Branch                ;
logic MemRead               ;
logic MemtoReg              ;
logic [3:0] ALUOp                 ;
logic MemWrite              ;
logic ALUSrc                ;
logic RegWrite              ;
logic BranchCorrect                  ;
logic [4:0] ALUControl      ; 
logic [1:0] RegWriteControl      ; 
logic PCSrc                 ;
 
  
      
Program_Counter pc(
    .clk_i   (clk_i)   ,
    .rst_n   (rst_n)   ,
    .pc_d    (pc_d )   ,
    .pc_q    (pc_q )
    );



Instruction_Memory ins_mem(
    .a     (pc_q[7:2] )     ,     //instruction address input
    .rd    (Instr)
    );
     
 
  
Register_File rf(
    .clk_i   (clk_i  )   ,
    .rst_n   (rst_n  )   ,
    .we3     (RegWrite    )   ,          //control signal
            
    .ra1     (Instr[19:15])   ,     //lw instruction rs
    .ra2     (Instr[24:20] )   ,     //
    .wa3     (Instr[11:7])   ,     //write address
    .wd3     (DataRF    )   ,  //write data         
   
    .rd1     (SrcA   )   ,      //read data
    .rd2     (SrcB   )
    
    );

ALU alu(
    .a     (SrcA) ,
    .b     (SrcBMuxOut) ,
    .F     (ALUControl) ,
    .y     (ALUResult) ,
    .branch_correct  (BranchCorrect)
    );
 

Data_Memory data_mem(
    .clk_i (clk_i)     ,
    .rst_n (rst_n)     ,
    .we    (MemWrite)          ,       //control signal
    .re    (MemRead)          ,       //control signal  
      
    .a     (ALUResult)     ,
    .wd    (SrcB)              ,
    .rd    (ReadData)
    );
 

ALU_Control_Unit alu_ctrl_unit(
    . funct3  (Instr[14:12])  ,
    . funct7  (Instr[31:25])  ,
    . ALUOp   (ALUOp)  ,    //4 bit
    . F       (ALUControl)  //5 bit
    );

Imm_Gen imm_generator(
    .instr         (Instr)     ,
    .extended_imm  (ExtImm)

    );


Control_Unit control(
    .opcode         (Instr[6:0] )     ,
    .Branch         (Branch   )       ,
    .MemRead        (MemRead  )       ,
    .MemtoReg       (MemtoReg )       ,
    .ALUOp          (ALUOp    )       ,
    .MemWrite       (MemWrite )       ,
    .ALUSrc         (ALUSrc   )       ,
    .RegWrite       (RegWrite )       ,
    .Jump           (Jump)            ,
    .RegWriteControl(RegWriteControl)
    );



// /////////////////   Shift Left     ///////////////////

assign ExtImm_shifted = { ExtImm[30:0] , 1'b0 };  

// /////////////////   AND Gate     ///////////////////

and and_gate(PCSrc,Branch,BranchCorrect);


// /////////////////   MUX data    ///////////////////

Mux mux_data(
    .sel   (MemtoReg) ,
    .a     (ReadData) ,        //sel=1
    .b     (ALUResult) ,         //sel=0
    .c     (Data)
    );


// /////////////////   MUX ALU     ///////////////////

Mux mux_alu(
    .sel   (ALUSrc) ,
    .a     (ExtImm) ,     //sel=1
    .b     (SrcB)   ,     //sel=0
    .c     (SrcBMuxOut)
    );


// /////////////////   MUX PC    ///////////////////

Mux mux_pc(
    .sel   (PCSrc)     ,
    .a     (PCPlusImm) ,     //sel=1
    .b     (PCPlus4)   ,     //sel=0
    .c     (PCNextOrBranch)
    );



////////////////////   Add (pc+imm)    ///////////////////

Add pc_plus_4(
    .a     (pc_q)  ,  
    .b     (32'd4)  ,  
    .sum   (PCPlus4) 
    );





////////////////////   Add (pc+imm)    ///////////////////
Add pc_plus_imm(
    .a     (pc_q) ,  
    .b     (ExtImm_shifted) ,  
    .sum   (PCPlusImm)
    );

////////////////////////////////////////////////////////

MUX_4to1 rf_control(
    .sel   (RegWriteControl)         , 
    .a     (Data)         ,                     
    .b     (PCPlus4)         ,                     
    .c     (ExtImm)         ,                     
    .d     (PCPlusImm)         ,                     
    .y     (DataRF)                

    );





///////////////////////////////////////


MUX_4to1 pc_control(
    .sel   ({ALUSrc,Jump})         , 
    .a     (PCNextOrBranch)         ,                     
    .b     (PCPlusImm)         ,                     
    .c     (PCNextOrBranch)         ,                     
    .d     (ALUResult)         ,                     
    .y     (pc_d)                

    );



// /////////////////   Sign Extend     ///////////////////
// assign    SignImm = { {16{Instr[15]}} ,Instr[15:0]};            
// assign    SrcB    = SignImm;


// /////////////////   Next Instruction PC + 4  ///////////////////
// assign    PCPlus4 =  pc_q + 4   ;            
// assign    pc_d    =  PCPlus4    ;

  
endmodule

