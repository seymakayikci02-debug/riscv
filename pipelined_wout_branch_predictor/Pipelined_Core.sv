`timescale 1ns / 1ps

module Pipelined_Core(
    input   logic clk_i,    
    input   logic rst_n,    
                            
    output [31:0] pc_q_out 
    );
    
logic IMID; 
logic IDEX;
logic EXMEM;   
logic MEMWB;   

logic  NextPC;
///////////////FETCH//////////////////
logic [31:0] IF_Instr           ; 
logic [31:0] IF_pc_q            ; 
logic [31:0] IF_PCPlus4         ;
logic [31:0] IF_PCNextOrBranch  ;
logic [31:0] IF_pc_d            ;
 
 
 
///////////////DECODE//////////////////
//IFID
logic [31:0] ID_pc_q       ;
logic [31:0] ID_Instr      ;          //Instr_ff

//IDEX
logic [31:0] ID_SrcA       ;
logic [31:0] ID_SrcB       ;
logic  ID_AluSrcA          ;  
logic  ID_AluSrcB          ; 
logic [1:0] ID_ResultSrc   ;
logic ID_MemWrite          ;
logic ID_RegWrite          ;
logic [4:0] ID_ALUControl  ;
logic ID_MemRead           ;
logic [31:0] ID_ImmExt     ;   


///////////////EXECUTE//////////////////
//IDEX
logic [31:0] EX_SrcA       ;
logic [31:0] EX_SrcB       ;
logic EX_MemRead           ;
logic EX_MemWrite          ;
logic [1:0] EX_ResultSrc   ;
logic [4:0] EX_ALUControl  ;
logic  EX_AluSrcA          ;  
logic  EX_AluSrcB          ; 
logic [31:0] EX_pc_q       ;





//EXMEM
logic [3:0] EX_LoadStoreControl;
logic [31:0] EX_ALUResult      ;
logic [31:0] EX_ImmExt         ;
     
logic [31:0] EX_SrcAMuxOut     ;  
logic [31:0] EX_SrcBMuxOut     ;  
logic [31:0] EX_SrcAMux4Out    ;  
logic [31:0] EX_SrcBMux5Out    ;                            
logic [31:0] EX_BranchCorrect  ;

logic [31:0] EX_Instr          ;

logic [31:0] EX_BWire          ;
logic [31:0] EX_AWire          ;
 

///////////////MEMORY//////////////////
//EXMEM
logic [31:0] MEM_SrcA             ;
logic [31:0] MEM_SrcB             ;
logic [3:0]  MEM_LoadStoreControl ;
logic [31:0] MEM_ALUResult        ;
logic MEM_ImmExt                  ;
logic MEM_MemRead                 ;
logic MEM_MemWrite                ;
logic [1:0] MEM_ResultSrc         ;
//MEMWB
logic [31:0] MEM_ReadData ; 
logic [31:0] MEM_Instr    ;


///////////////WRITEBACK//////////////////
logic [31:0] WB_ReadData  ; 
logic [31:0] WB_Instr     ;
logic [31:0] WB_Result    ;
logic [1:0]  WB_ResultSrc ;
logic [31:0] WB_ALUResult ;


///////////////INSIDE WIRES//////////////////
logic [1:0] ForwardA; 
logic [1:0] ForwardB; 

logic MEM_RegWrite      ; 
logic WB_RegWrite       ;
logic [31:0] MEM_BWire  ;


logic FlushD  ;
logic FlushE  ;
logic StallF  ;
logic StallD  ;
logic StallD_ff;


  
logic [1:0] EX_TargetBaseSel   ;
logic  EX_PCAddrSel            ;                     
logic [31:0] EX_TargetAddrBase ;
logic [31:0] EX_TargetAddr     ;
logic [31:0] EX_PCPlusImm;



 ////////////////////////////////////////////////FETCH/////////////////////////////////////////////////////////////


Mux mux1(
    .sel   (EX_PCAddrSel   ) ,
    .a     (EX_TargetAddr  ) ,     //sel=1
    .b     (IF_PCPlus4     ) ,     //sel=0
    .c     (IF_pc_d        )
    );


      
Program_Counter pc(
    .clk_i   (clk_i     ) ,
    .rst_n   (rst_n     ) ,
    .pc_en_n (StallF     ) ,
    .pc_d    (IF_pc_d   ) ,    //NextOrBranch
    .pc_q    (IF_pc_q   )
    );
 

Add pc_plus_4(
    .a     (IF_pc_q   ) ,  
    .b     (32'd4     ) ,  
    .sum   (IF_PCPlus4) 
    );                 
 
 
 
 
Instruction_Memory ins_mem(
    .a     (IF_pc_q[7:2]    ),     //instruction address input
    .rd    (IF_Instr        )
    );
      
 ///////////////////////////////////////////////////////////DECODE///////////////////////////////////////////
  
Register_File rf(
    .clk_i   (clk_i          ) ,
    .rst_n   (rst_n          ) ,
    .we3     (WB_RegWrite    ) ,               
    .ra1     (ID_Instr[19:15]) ,     
    .ra2     (ID_Instr[24:20]) ,     
    .wa3     (WB_Instr[11:7] ) ,     
    .wd3     (WB_Result      ) ,             
    .rd1     (ID_SrcA        ) ,     
    .rd2     (ID_SrcB        )       
   
    );




Control_Unit control(
    .clk_i       (clk_i          )  ,
    .rst_n       (rst_n          )  ,
    .opcode      (ID_Instr[6:0]  )  ,
    .funct3      (ID_Instr[14:12])  ,
    .funct7      (ID_Instr[31:25])  ,
    .Branch      (EX_BranchCorrect)  ,      //input
    .AluSrcA     (ID_AluSrcA     )  ,
    .AluSrcB     (ID_AluSrcB     )  ,
    .ALUControl  (ID_ALUControl  )  ,
    .RegWrite    (ID_RegWrite    )  , 
    .MemWrite    (ID_MemWrite    )  , 
    .MemRead     (ID_MemRead     )  ,    
    .ResultSrc   (ID_ResultSrc   )              
    );   



Imm_Gen imm_generator(
    .instr         (ID_Instr)     ,
    .extended_imm  (ID_ImmExt)

    );


 ///////////////////////////////////////////////////////////EXECUTE///////////////////////////////////////////
  


Mux mux3(
    .sel   (EX_AluSrcB   ) ,
    .a     (EX_BWire     ) ,     //sel=1
    .b     (EX_ImmExt    ) ,     //sel=0
    .c     (EX_SrcBMuxOut)
    );





MUX_4to1 mux4(                    
     .sel   (ForwardA     ) , 
     .a     (EX_SrcA      ) ,          //2'b00               
     .b     (MEM_ALUResult) ,          //2'b01               
     .c     (WB_Result    ) ,          //2'b10               
     .d     (             ) ,          //2'b11               
     .y     (EX_AWire     )                
     );
 
 
 
 
 MUX_4to1 mux5(               
     .sel   (ForwardB     ), 
     .a     (EX_SrcB      ),     //2'b00            
     .b     (MEM_ALUResult),     //2'b01           
     .c     (WB_Result)    ,     //2'b10           
     .d     ( )            ,     //2'b11           
     .y     (EX_BWire)                
     );


Mux mux2(
    .sel   (EX_AluSrcA   ) ,
    .a     (EX_AWire     ) ,     //sel=1
    .b     (EX_pc_q      ) ,     //sel=0
    .c     (EX_SrcAMuxOut)
    );



ALU alu(
    .a             (EX_SrcAMuxOut)      ,
    .b             (EX_SrcBMuxOut)      ,
    .F             (EX_ALUControl)      ,
    .y             (EX_ALUResult )      ,
    .branch_correct(EX_BranchCorrect)   ,
    .ls_control    (EX_LoadStoreControl)
    );
 
 
 
Forwarding_Unit forwarding_unit(

    .clk_i     (clk_i           ),
    .rst_n     (rst_n           ),
    .Rs1       (EX_Instr [19:15]),
    .Rs2       (EX_Instr [24:20]),
    .RdMem     (MEM_Instr[11:7] ),  
    .RdWb      (WB_Instr [11:7] ),
    .weMEM     (MEM_RegWrite    ), 
    .weWB      (WB_RegWrite     ),   
    .ForwardA  (ForwardA        ),
    .ForwardB  (ForwardB        )
    
    );
 
 
 Hazard_Detection_Unit hazard_detection(
    .clk_i                 (clk_i           )   ,
    .rst_n                 (rst_n           )   ,
    .BranchCorrect         (EX_BranchCorrect)   ,
    .opcode                (EX_Instr[6:0]   )   ,
    .RdEx                  (EX_Instr[11:7]  )   ,
    .Rs1                   (ID_Instr[19:15] )   ,
    .Rs2                   (ID_Instr[24:20] )   ,
    .TargetBaseSel         (EX_TargetBaseSel)   ,
    .PCAddrSel             (EX_PCAddrSel    )   ,
    .flush_de              (FlushD          )   ,
    .flush_ex              (FlushE          )   ,     
    .stall_fe              (StallF          )   ,
    .stall_de              (StallD          )
      
    
    );
 
 
 
MUX_4to1 mux7(                    
     .sel   (EX_TargetBaseSel) , 
     .a     (EX_AWire         ) ,          //2'b00               
     .b     (EX_pc_q         ) ,          //2'b01               
     .c     (EX_pc_q         ) ,          //2'b10               
     .d     (                ) ,          //2'b11               
     .y     (EX_TargetAddrBase)                
     );


Add pc_plus_imm(          
    .a     (EX_TargetAddrBase  ) ,       
    .b     (EX_ImmExt) ,     
    .sum   (EX_TargetAddr)    
    );

 
 
 
 
 ///////////////////////////////////////////////////////////MEMORY///////////////////////////////////////////
 

Data_Memory data_mem(
    .clk_i           (clk_i)             ,
    .rst_n           (rst_n)             ,
    .we              (MEM_MemWrite)      ,  //control signal
    .re              (MEM_MemRead)       ,  //control signal  
   
    .a               (MEM_ALUResult)     ,  //address
    .wd              (MEM_BWire)          ,
    .ls_control      (MEM_LoadStoreControl),
    .rd              (MEM_ReadData)
    );





///////////////////////////////////////////////////////////WRITEBACK///////////////////////////////////////////
 

Mux mux6(
    .sel   (WB_ResultSrc )   ,
    .a     (WB_ReadData  )   ,     //sel=1
    .b     (WB_ALUResult )   ,     //sel=0
    .c     (WB_Result    )
    );



/////////////////////// Pipeline Blocks ///////////////////////////


always_ff@(posedge clk_i) begin

    if(!rst_n) begin          
                 
        ID_pc_q       <=0;
        ID_Instr      <=0;              
        
        EX_SrcA             <=0;
        EX_SrcB             <=0;
        EX_MemRead          <=0;     
        EX_MemWrite         <=0;     
        EX_ResultSrc        <=0;
        EX_ALUControl       <=0;
        EX_AluSrcA          <=0;
        EX_AluSrcB          <=0;                         
        EX_ImmExt           <=0;                          
        EX_SrcAMux4Out      <=0;
        EX_SrcBMux5Out      <=0;                       
        EX_Instr            <=0;
            
        MEM_SrcA            <=0;       
        MEM_SrcB            <=0;       
        MEM_LoadStoreControl<=0;
        MEM_ALUResult       <=0;
        MEM_ImmExt          <=0;       
        MEM_MemRead         <=0;       
        MEM_MemWrite        <=0;       
        MEM_ResultSrc       <=0;                          
        MEM_Instr           <=0;
           
        WB_ReadData         <=0;
        WB_Instr            <=0;  
        WB_ALUResult        <=0;   
    end
    else begin
        if      (FlushD) ID_Instr <= 0       ;
        else             ID_Instr <= IF_Instr;  
                                   
        ID_pc_q      <=  IF_pc_q      ; 

        if     (FlushE && !StallD) begin
            EX_Instr  <= 0        ; 
        end
        
        else if(FlushE && StallD) begin  
            EX_Instr  <= 0        ;         
            StallD_ff <=  StallD;       
            ID_Instr   <=  ID_Instr;        
        end                             
                                    
        else  begin                     
            EX_Instr  <= ID_Instr ;          
        end                             
            
            
        if(StallD) begin                                 
            ID_pc_q      <=  ID_pc_q      ;
        end       
        else begin
           EX_pc_q      <=  ID_pc_q      ;                                                  
        end     
        
        EX_SrcA      <=  ID_SrcA      ; 
        EX_SrcB      <=  ID_SrcB      ; 
        EX_AluSrcA   <=  ID_AluSrcA   ; 
        EX_AluSrcB   <=  ID_AluSrcB   ; 
        EX_ALUControl<=  ID_ALUControl; 
        
                                        
        EX_MemWrite  <=  ID_MemWrite  ; 
        EX_MemRead   <=  ID_MemRead   ; 
        EX_ImmExt    <=  ID_ImmExt    ; 
        EX_ResultSrc <=  ID_ResultSrc ; 
        //EX_RegWrite  <=  ID_RegWrite  ; 
        
        
        
        
           
        MEM_BWire    <=  EX_BWire     ;
        MEM_SrcB     <=  EX_SrcB      ;
        MEM_MemRead  <=  EX_MemRead   ;         
        MEM_MemWrite <=  EX_MemWrite  ;         
        //MEM_RegWrite <=  EX_RegWrite  ;

        MEM_LoadStoreControl<=EX_LoadStoreControl; 
        MEM_ALUResult       <=EX_ALUResult       ; 
        MEM_Instr           <=EX_Instr           ; 
        MEM_ResultSrc       <=EX_ResultSrc       ;
        
        WB_RegWrite  <= MEM_RegWrite   ;
        WB_ALUResult <= MEM_ALUResult  ;                        
        WB_ReadData  <= MEM_ReadData   ;   
        WB_Instr     <= MEM_Instr      ;
        WB_ResultSrc <= MEM_ResultSrc  ;
    end

end
  
endmodule    
    
    
    
