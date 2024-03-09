module decode(
    input clk,
    input [3:0] D_icode, D_ifun, D_rA, D_rB,D_stat,
    input [63:0] D_valC, D_valP,


//data forwarding
    
    input [3:0] W_icode, W_dstE, W_dstM,
    input [63:0] in_reg0,in_reg1,in_reg2,in_reg3,in_reg4,in_reg5,in_reg6,in_reg7,in_reg8,in_reg9,in_reg10,in_reg11,in_reg12,in_reg13,in_reg14,
    input [63:0] W_valE, W_valM,
    
    input [3:0] e_dstE,
    input [3:0] M_dstE,
    input [3:0] M_dstM,

    input E_bubble, //bubble flag for execute stage
 
    input  [63:0] e_valE,
    input  [63:0] M_valE,
    input  [63:0] m_valM,

    
    output reg [3:0] E_icode, E_ifun,                              // pipe registers for execute stage (output)
    output reg [63:0] E_valA, E_valB, E_valC,
    output reg [3:0] E_srcA, E_srcB, E_dstE, E_dstM,  
    output reg [0:3] E_stat,                                 // bubble flag for execute stage
   
    output reg [63:0] reg_mem0,reg_mem1,reg_mem2,reg_mem3,reg_mem4,reg_mem5,reg_mem6,reg_mem7,reg_mem8,reg_mem9,reg_mem10,reg_mem11,reg_mem12,reg_mem13,reg_mem14,

output reg [3:0] d_srcA ,d_srcB
  

   



    // output reg  [63:0] register_value0,
    // output reg  [63:0] register_value1,
    // output reg  [63:0] register_value2,
    // output reg  [63:0] register_value3,
    // output reg  [63:0] register_value4,
    // output reg  [63:0] register_value5,
    // output reg  [63:0] register_value6,
    // output reg  [63:0] register_value7,
    // output reg  [63:0] register_value8,
    // output reg  [63:0] register_value9,
    // output reg  [63:0] register_value10,
    // output reg  [63:0] register_value11,
    // output reg  [63:0] register_value12,
    // output reg  [63:0] register_value13,
    // output reg  [63:0] register_value14
                                  
);

//array of registers
reg  [63:0] register_file[0:14];
reg [63:0] d_rvalA, d_rvalB;

    reg [63:0] d_valA ,d_valB, d_valC;
    reg [3:0] d_dstE ,d_dstM;
   
   reg [3:0] d_icode ,d_ifun;
   reg [3:0] d_stat;

initial begin
    register_file[0]=64'd0;
    register_file[1]=64'd1;
    register_file[2]=64'd0;
    register_file[3]=64'd0;
    register_file[4]=64'd4;
    register_file[5]=64'd5;
    register_file[6]=64'd6;
    register_file[7]=64'd7;
    register_file[8]=64'd8;
    register_file[9]=64'd9;
    register_file[10]=64'd10;
    register_file[11]=64'd11;
    register_file[12]=64'd12;
    register_file[13]=64'd13;
    register_file[14]=64'd14;

end





  // implementing data forwarding
always @(*) 
begin

    // forwarding data for valA
    if (D_icode==4'h8 | D_icode==4'h7)          // use the incremented PC (for hump and call)
    begin
        d_valA = D_valP;
    end
    else if (d_srcA == e_dstE & e_dstE!=4'hF)   // forward valE from execute
    begin
        d_valA = e_valE;
    end
    else if (d_srcA == M_dstM & M_dstM!=4'hF)   // forward valM from memory
    begin
        d_valA = m_valM;
    end
    else if (d_srcA == M_dstE & M_dstE!=4'hF)   // forward valE from memory
    begin
        d_valA = M_valE;
    end
    else if (d_srcA == W_dstM & W_dstM!=4'hF)   // forward valM from writeback
    begin
        d_valA = W_valM;
    end
    else if (d_srcA == W_dstE & W_dstE!=4'hF)   // forward valE from writeback
    begin
        d_valA = W_valE;
    end
    else                                         // use value read from register
    begin
        d_valA = d_rvalA;
    end



    // forwarding data for valB
    /*if (D_icode==4'h9 | D_icode==4'h7)  // use the incremented PC
    begin
        d_valB = D_valP;
    end*/
    if (d_srcB == e_dstE & e_dstE!=4'hF)          // forward valE from execute
    begin
        d_valB = e_valE;
    end
    else if (d_srcB == M_dstM & M_dstM!=4'hF)          // forward valM from memory
    begin
        d_valB = m_valM;
    end
    else if (d_srcB == M_dstE & M_dstE!=4'hF)          // forward valE from memory
    begin
        d_valB = M_valE;
    end
    else if (d_srcB == W_dstM & W_dstM!=4'hF)          // forward valM from writeback
    begin
        d_valB = W_valM;
    end
    else if (d_srcB == W_dstE & W_dstE!=4'hF)          // forward valE from writeback
    begin
        d_valB = W_valE;
    end
    else                                // use value read from register
    begin
        d_valB = d_rvalB;
    end
end

always@(*)
begin

    d_icode = D_icode;
    d_ifun  = D_ifun;
    d_valC = D_valC;
    d_stat = D_stat;
    d_srcA = 4'hF;
    d_srcB = 4'hF;
    d_dstE = 4'hF;
    d_dstM = 4'hF;

    if(D_icode == 4'b0010) //cmovxx 2
    begin
        d_rvalA=register_file[D_rA];
        d_rvalB = 0;
        d_srcA = D_rA;
        d_dstE = D_rB;
    end

    else if(D_icode == 4'b0011) //irmov 3
    begin
        d_dstE = D_rB;
    end

    else if(D_icode == 4'b0100) //rmmov 4
    begin
        d_rvalA = register_file[D_rA];
        d_rvalB = register_file[D_rB];
        d_srcA = D_rA;
        d_srcB = D_rB;
    end

    else if (D_icode == 4'b0101) //mrmov 5
    begin
        d_rvalB = register_file[D_rB];
        d_srcB = D_rB;
        d_dstM = D_rA;
    end

    else if(D_icode == 4'b0110) //opq 6
    begin
        d_rvalA = register_file[D_rA];
        d_rvalB = register_file[D_rB];
        d_srcA = D_rA;
        d_srcB = D_rB;
        d_dstE = D_rB; 
    end

    else if(D_icode == 4'b0111) //jxx 7
    begin
    end

        else if(D_icode == 4'b1000) //call 8
    begin
        d_rvalB = register_file[4];
        d_srcB = 4;
        d_dstE = 4;
    end

    else if(D_icode == 4'b1001) // ret 9
    begin
        d_rvalA = register_file[4];
        d_rvalB = register_file[4];
        d_srcA = 4;
        d_srcB = 4;
        d_dstE = 4;
    end

    else if (D_icode == 4'b1010) //push A
    begin
        d_rvalA = register_file[D_rA];
        d_rvalB = register_file[4]; //%rsp
        d_srcA = D_rA;
        d_srcB = 4;
        d_dstE = 4;
    end

    else if(D_icode == 4'b1011) //pop B
    begin
        d_rvalA = register_file[4]; //%rsp
        d_rvalB = register_file[4]; //%rsp
        d_srcA = 4;
        d_srcB = 4;
        d_dstE = 4;
        d_dstM = D_rA;
    end
end

always @(posedge clk) begin
    if(E_bubble)
    begin
        E_stat <= 4'b1000;
        E_icode <= 4'b0001;
        E_ifun <= 4'b0000;
        E_dstE <= 4'hF;
        E_dstM <= 4'hF;
        
        E_valA <= 4'b0000;
        E_valB <= 4'b0000;
        E_valC <= 4'b0000;
    end  
    else
    begin
        E_stat <= d_stat;
        E_icode<= d_icode;
        E_ifun <= d_ifun;
        E_dstE <= d_dstE;
        E_dstM <= d_dstM;
        
        E_valA <= d_valA;
        E_valB <= d_valB;
        E_valC <= d_valC;
    end 
end

    always @(posedge clk) begin
        case(W_icode)
            4'b0000, 4'b0001, 4'b0100, 4'b0111: begin     // No writeback for these instructions
                // No writeback stage here
            end
            4'b0010, 4'b0011, 4'b0110, 4'b1000,          // Writeback to W_dstE
            4'b1001, 4'b1010: begin
                register_file[W_dstE] = W_valE;
            end
            4'b0101: begin                               // Writeback to W_dstM
                register_file[W_dstM] = W_valM;
            end
            4'b1011: begin                               // Writeback to both W_dstE and W_dstM
                register_file[W_dstE] = W_valE;
                register_file[W_dstM] = W_valM;
            end
        endcase
    end

    always @(posedge clk) begin
        reg_mem0 <= register_file[0];
        reg_mem1 <= register_file[1];
        reg_mem2 <= register_file[2];
        reg_mem3 <= register_file[3];
        reg_mem4 <= register_file[4];
        reg_mem5 <= register_file[5];
        reg_mem6 <= register_file[6];
        reg_mem7 <= register_file[7];
        reg_mem8 <= register_file[8];
        reg_mem9 <= register_file[9];
        reg_mem10 <= register_file[10];
        reg_mem11 <= register_file[11];
        reg_mem12 <= register_file[12];
        reg_mem13 <= register_file[13];
        reg_mem14 <= register_file[14];
    end

endmodule