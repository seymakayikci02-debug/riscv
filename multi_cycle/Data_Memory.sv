`timescale 1ns / 1ps

module Data_Memory(         //little endian memory addressing
    input clk_i,
    input rst_n,
    input we,       //control signal
    input re,       //control signal
    
    input [31:0] a,
    input [31:0] wd,
    input [3:0] ls_control, 
    output logic [31:0] rd
    );
    
//Dimensions before the variable name → packed
//Dimensions after the variable name  → unpacked
logic  [31:0][63:0] data_mem ;
logic  [15:0]   rd_byte_data  ;
typedef enum logic [3:0]{
                        LB   =  4'b0000,
                        LH   =  4'b0001,
                        LW   =  4'b0010,
                        LBU  =  4'b0011,
                        LHU  =  4'b0100,
                         
                        SB   =  4'b0101,
                        SH   =  4'b0110,
                        SW   =  4'b0111
                        }ls_numeric;


//////////store//////////////

always_ff@(posedge clk_i) begin
    if(!rst_n) begin
        data_mem  <= '{default: '0} ;
    end
    
    else begin
        if(we) begin
            case(ls_control)
       
            SB     :   begin           
                if(a[1:0]==2'b00) begin       
                    data_mem [a[31:2]][7:0] <= $signed(wd[7:0]) ;                                   
                end
                                
                else if(a[1:0]==2'b01) begin
                    data_mem [a[31:2]][15:8]  <= $signed(wd[7:0]) ;                          
                end
                 
                else if(a[1:0]==2'b10) begin
                    data_mem [a[31:2]][23:16] <= $signed(wd[7:0]) ;                       
                end 
            
                else if(a[1:0]==2'b11) begin
                    data_mem [a[31:2]][31:24] <= $signed(wd[7:0]) ;                       
                end                       
            end   
             
            SH     : begin
                if(a[1:0]==2'b00) begin       
                    data_mem [a[31:2]][7:0] <= $signed(wd[7:0]) ;
                    data_mem [a[31:2]][15:8] <= $signed(wd[15:8]) ;                                                      
                end
                
                else if(a[1:0]==2'b01) begin
                    data_mem [a[31:2]][15:8]  <= $signed(wd[7:0]) ;
                    data_mem [a[31:2]][23:16] <= $signed(wd[15:8]) ;
                end
                 
                else if(a[1:0]==2'b10) begin
                    data_mem [a[31:2]][23:16] <= $signed(wd[7:0]) ;
                    data_mem [a[31:2]][31:24] <= $signed(wd[15:8]) ;                       
                end 
            
            end
            
            SW     : begin
                data_mem [a[31:2]][7:0]   <= $signed(wd[7:0]) ;     
                data_mem [a[31:2]][15:8]  <= $signed(wd[15:8]) ;   
                data_mem [a[31:2]][23:16] <= $signed(wd[23:16]) ; 
                data_mem [a[31:2]][31:24] <= $signed(wd[31:24]) ;               
            end                      
            endcase
          
        end                   
    end
end

///////////////load//////////////////

always_comb begin

    if(!rst_n) begin
        rd_byte_data  = '{default: '0} ;
        rd = '{default: '0} ;
    end
    
    else begin
    
        if(re) begin
                case(ls_control)
                
                LB     :   begin           
                    if(a[1:0]==2'b00) begin       
                      rd_byte_data[7:0] =  data_mem [a[31:2]][7:0]   ;  
                      rd = { {24{rd_byte_data[7]} }  ,rd_byte_data[7:0]}  ;                          
                    end
                                    
                    else if(a[1:0]==2'b01) begin
                         rd_byte_data[7:0] =  data_mem [a[31:2]][15:8]   ;                              
                         rd = { {24{rd_byte_data[7]} }  ,rd_byte_data[7:0]}  ;                                                              
                    end
                     
                    else if(a[1:0]==2'b10) begin
                        rd_byte_data[7:0] =  data_mem [a[31:2]][23:16]   ;                            
                        rd = { {24{rd_byte_data[7]} }  ,rd_byte_data[7:0]}  ;                                                                                        
                    end 
                
                    else if(a[1:0]==2'b11) begin
                         rd_byte_data[7:0] =  data_mem [a[31:2]][31:24]   ;           
                         rd = { {24{rd_byte_data[7]} }  ,rd_byte_data[7:0]}  ;                                         
                    end                       
                end   
                 
                LH     : begin
                    if(a[1:0]==2'b00) begin       
                        rd_byte_data[7:0] =  data_mem [a[31:2]][7:0]   ; 
                        rd_byte_data[15:8] =  data_mem [a[31:2]][15:8]   ; 
                        rd = { {16{rd_byte_data[15]} }, rd_byte_data[15:8] ,rd_byte_data[7:0]}  ;         
                                
                                                                              
                    end
                    
                    else if(a[1:0]==2'b01) begin
                        rd_byte_data[7:0]  =  data_mem [a[31:2]][15:8]   ;                         
                        rd_byte_data[15:8] =  data_mem [a[31:2]][23:16]   ;                       
                        rd = { {16{rd_byte_data[15]} }, rd_byte_data[15:8] ,rd_byte_data[7:0]}  ; 
                        
                    end
                     
                    else if(a[1:0]==2'b10) begin
                        rd_byte_data[7:0]  =  data_mem [a[31:2]][23:16]   ;                       
                        rd_byte_data[15:8] =  data_mem [a[31:2]][31:24]   ;                      
                        rd = { {16{rd_byte_data[15]} }, rd_byte_data[15:8] ,rd_byte_data[7:0]}  ;                        
                    end 
                
                end
                
                LW     : begin
                       rd = data_mem [a[31:2]]  ;         
                end
                
                
                LBU   : begin
                
                    if(a[1:0]==2'b00) begin                                        
                      rd_byte_data[7:0] =  data_mem [a[31:2]][7:0]   ;                 
                      rd = { {24{1'b0} }  ,rd_byte_data[7:0]}  ;     
                    end                                                         
                                                                               
                    else if(a[1:0]==2'b01) begin                                
                         rd_byte_data[7:0] =  data_mem [a[31:2]][15:8]   ;      
                         rd = { {24{1'b0} }  ,rd_byte_data[7:0]}  ;  
                    end                                                         
                
                    else if(a[1:0]==2'b10) begin                                
                        rd_byte_data[7:0] =  data_mem [a[31:2]][23:16]   ;      
                        rd = { {24{1'b0} }  ,rd_byte_data[7:0]}  ;   
                    end                                                         
                
                    else if(a[1:0]==2'b11) begin                                
                         rd_byte_data[7:0] =  data_mem [a[31:2]][31:24]   ;     
                         rd = { {24{1'b0} }  ,rd_byte_data[7:0]}  ;  
                    end                                                         
               
                end
                
                LHU   : begin
                
                    if(a[1:0]==2'b00) begin                                                      
                        rd_byte_data[7:0] =  data_mem [a[31:2]][7:0]   ;                                
                        rd_byte_data[15:8] =  data_mem [a[31:2]][15:8]   ;                       
                        rd = { {16{1'b0}} , rd_byte_data[15:8] ,rd_byte_data[7:0]}  ;                                                                                                                                                                                           
                    end                                                                          
                
                    else if(a[1:0]==2'b01) begin                                                 
                        rd_byte_data[7:0]  =  data_mem [a[31:2]][15:8]   ;                       
                        rd_byte_data[15:8] =  data_mem [a[31:2]][23:16]   ;                      
                        rd = { {16{1'b0}}  , rd_byte_data[15:8] ,rd_byte_data[7:0]}  ;             
                    end                                                                          
                
                    else if(a[1:0]==2'b10) begin                                                 
                        rd_byte_data[7:0]  =  data_mem [a[31:2]][23:16]   ;                      
                        rd_byte_data[15:8] =  data_mem [a[31:2]][31:24]   ;                      
                        rd = { {16{1'b0}} , rd_byte_data[15:8] ,rd_byte_data[7:0]}  ; 
                    end    
                                                                                          
                end
             
                endcase
                
            end 
            
            else begin
                rd_byte_data[7:0]  = '{default : '0};
                rd_byte_data[15:8] = '{default : '0};
                rd ='{default : '0};
            end
                         
    end
end
       
endmodule
