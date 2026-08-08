`timescale 1ns / 1ps


module Multi_Cycle_Core(
    input   logic clk_i,    
    input   logic rst_n,    
                            
    output [31:0] pc_q_out  
    );
    
logic [31:0] SrcAMuxOut         ; 
logic [31:0] SrcBMuxOut         ;  
logic [31:0] ALUResultMuxOut    ;
logic [31:0] DataMemoryAddress  ;
  
logic [31:0] pc_d           ;
logic [31:0] pc_q           ;
logic [31:0] Instr          ;
logic [31:0] SrcA           ;
logic [31:0] SrcB           ;             
logic [31:0] ALUResult      ;               
logic [31:0] ReadData       ; 
logic [31:0] ExtImm         ;
logic [31:0] DataRF         ; 


//control signals//

logic Branch                    ;
logic MemRead                   ;
logic [3:0] ALUOp               ;
logic [3:0] LoadStoreControl    ;
logic [3:0] LoadStoreControl_ff ;
logic MemWrite                  ;
logic ALUSrc                    ;
logic RegWrite                  ;
logic BranchCorrect             ;
logic [4:0] ALUControl          ; 
logic IRWrite                   ;
logic PCWrite                   ;
logic [1:0] AluSrcA             ;
logic [1:0] AluSrcB             ;
logic [1:0] ResultSrc           ;


///////flip_flops/////////////////
logic [31:0] SrcA_ff       ;           
logic [31:0] SrcB_ff       ;                                       
logic [31:0] ALUResult_ff  ;                           
logic [31:0] ReadData_ff   ;   
logic [31:0] pc_q_old      ;
logic [31:0] Instr_ff      ;

  
      
Program_Counter pc(
    .clk_i   (clk_i)   ,
    .rst_n   (rst_n)   ,
    .PCWrite (PCWrite) ,
    .pc_d    (pc_d )   ,
    .pc_q    (pc_q )
    );
 
 
 
Instruction_Memory ins_mem(
    .a     (pc_q[6:2] )     ,     //instruction address input
    .rd    (Instr)
    );
      
 
  
Register_File rf(
    .clk_i   (clk_i  )   ,
    .rst_n   (rst_n  )   ,
    .we3     (RegWrite ) ,          //control signal           
    .ra1     (Instr_ff[19:15]) ,     //lw instruction rs
    .ra2     (Instr_ff[24:20]) ,     //
    .wa3     (Instr_ff[11:7])  ,     //write address
    .wd3     (DataRF )         ,  //write data           
    .rd1     (SrcA   )         ,      //read data
    .rd2     (SrcB   )
    
    );

ALU alu(
    .a     (SrcAMuxOut) ,
    .b     (SrcBMuxOut) ,
    .F     (ALUControl) ,
    .y     (ALUResult) ,
    .branch_correct  (BranchCorrect),
    .ls_control      (LoadStoreControl)
    );
 

Data_Memory data_mem(
    .clk_i           (clk_i)                 ,
    .rst_n           (rst_n)                 ,
    .we              (MemWrite)              ,       //control signal
    .re              (MemRead)               ,       //control signal  
   
    .a               (DataMemoryAddress)     ,  //address
    .wd              (SrcB_ff)               ,
    .ls_control      (LoadStoreControl_ff)      ,
    .rd              (ReadData)
    );


Imm_Gen imm_generator(
    .instr         (Instr_ff)     ,
    .extended_imm  (ExtImm)

    );


FSM_Multi_Control control(
    .clk_i            (clk_i      )       ,
    .rst_n            (rst_n      )       ,
    .opcode           (Instr_ff[6:0] )       ,
    .funct3           (Instr_ff[14:12]  )    ,
    .funct7           (Instr_ff[31:25]  )    ,
    .Branch           (BranchCorrect )    , 
    .AluSrcA          (AluSrcA    )       ,
    .AluSrcB          (AluSrcB    )       ,
    .ALUControl       (ALUControl )       ,
    .IRWrite          (IRWrite    )       ,
    .PCWrite          (PCWrite    )       ,
    .RegWrite         (RegWrite   )       , 
    .MemWrite         (MemWrite   )       , 
    .MemRead          (MemRead    )       ,    
    .ResultSrc        (ResultSrc  )              
    );             


// /////////////////   MUX 2    ///////////////////

MUX_4to1 mux2(
    .sel   (AluSrcA)    , 
    .a     (pc_q)       ,       //2'b00               
    .b     (pc_q_old)   ,       //2'b01               
    .c     (SrcA_ff)    ,       //2'b10               
    .d     (SrcA )          ,       //2'b11               
    .y     (SrcAMuxOut)                
    );


// /////////////////   MUX 3    ///////////////////

MUX_4to1 mux3(
    .sel   (AluSrcB)    , 
    .a     (SrcB_ff)    ,     //2'b00            
    .b     (ExtImm)     ,     //2'b01           
    .c     (32'd4)       ,     //2'b10           
    .d     ( )          ,     //2'b11           
    .y     (SrcBMuxOut)                
    );


// /////////////////   MUX 4    ///////////////////

MUX_4to1 mux4(
    .sel   (ResultSrc)    , 
    .a     (ALUResult_ff) ,    //2'b00            
    .b     (ReadData_ff)  ,    //2'b01           
    .c     (ALUResult)    ,    //2'b10           
    .d     (ExtImm )      ,    //2'b11           
    .y     (ALUResultMuxOut)                
    );

///////////////    wire connections    ///////////////////

assign pc_q_out = pc_q;

assign DataMemoryAddress = ALUResultMuxOut;
assign DataRF            = ALUResultMuxOut;
assign pc_d              = ALUResultMuxOut;


////////////       flip flops       //////////////////////

always_ff@(posedge clk_i) begin
    if(!rst_n) begin
        pc_q_old            <= '{default:'0};
        Instr_ff            <= '{default:'0};
        SrcA_ff             <= '{default:'0};
        SrcB_ff             <= '{default:'0};
        ALUResult_ff        <= '{default:'0};            
        LoadStoreControl_ff <= '{default:'0};                                          
        ReadData_ff         <= '{default:'0};                 
    end
    
    else begin
        if(IRWrite==1'b0)  begin
            pc_q_old        <= pc_q_old ;
            Instr_ff        <= Instr_ff;
            end
            
        else if(IRWrite==1'b1)  begin
            Instr_ff        <= Instr;
            pc_q_old        <= pc_q ;
        end
        
        SrcA_ff             <= SrcA;
        SrcB_ff             <= SrcB;
    
        ALUResult_ff        <= ALUResult;
        LoadStoreControl_ff <= LoadStoreControl;
    
        ReadData_ff         <= ReadData;
        
    end   
end

 
endmodule
