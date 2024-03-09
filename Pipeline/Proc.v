`include "pipe_fetch.v"
`include "decode.v"
`include "pipe_execute.v"

`include "pipe_memory.v"
`include "pipe_control.v"

module Proc;

reg clk;
// reg [63:0];


reg [63:0] F_predPC;
wire [63:0] predPC;
reg [0:3] stat = 4'b1000;
wire hlt;


//-------------------DECODE--------------------
// decode pipe registers
wire [3:0] D_icode, D_ifun, D_rA, D_rB;
wire [63:0] D_valC, D_valP;
wire [0:3] D_stat;
// decode signals
wire [3:0] d_srcA, d_srcB;
wire [3:0] d_ifun,d_icode,d_stat;
wire [3:0] d_dstE ,d_dstM;
wire [63:0] d_valA ,d_valB, d_valC;
wire imem_error,instr_valid;
//write back signals
wire [63:0] in_reg0,in_reg1,in_reg2,in_reg3,in_reg4,in_reg5,in_reg6,in_reg7,in_reg8,in_reg9,in_reg10,in_reg11,in_reg12,in_reg13,in_reg14;
wire [63:0] reg_mem0,reg_mem1,reg_mem2,reg_mem3,reg_mem4,reg_mem5,reg_mem6,reg_mem7,reg_mem8,reg_mem9,reg_mem10,reg_mem11,reg_mem12,reg_mem13,reg_mem14;
wire [3:0] w_stat;


//-------------------EXECUTE--------------------
// execute pipe registers
wire [3:0] E_icode, E_ifun;
wire  [63:0] E_valA, E_valB, E_valC;
wire [3:0] E_srcA, E_srcB, E_dstE, E_dstM;
wire [0:3] E_stat;
// execute signals
wire [3:0] e_dstE;
wire  [63:0] e_valE;
wire e_cnd;


//-------------------MEMORY--------------------
// memory pipe registers
wire [3:0] M_icode, M_dstE, M_dstM;
wire  [63:0] M_valA, M_valE;
wire [0:3] M_stat;
wire M_cnd;
// memory signals
wire  [63:0] m_valM;
wire [0:3] m_stat;

//-------------------WRITEBACK-----------------
// writeback pipe registers
wire [0:3] W_stat; 
wire [3:0] W_icode, W_dstE, W_dstM;
wire  [63:0] W_valE, W_valM;




//-----------STALLS AND BUBBLES----------------
wire F_stall, D_stall, D_bubble, E_bubble, M_bubble, W_stall, set_cc;


// clock of T = 20
always #10 clk = ~clk;



fetch fetch1(
    .clk(clk),
    .F_stall(F_stall),
    .D_stall(D_stall),
    .D_bubble(D_bubble),
    
    .M_icode(M_icode),
    .M_cnd(M_cnd),
    .M_valA(M_valA),
    .W_icode(W_icode),
    .W_valM(W_valM),
    .F_predPC(F_predPC),
    .predPC(predPC),
    .D_stat(D_stat),
    .D_icode(D_icode),
    .D_ifun(D_ifun),
    .D_valC(D_valC),
    .D_valP(D_valP),
    .D_rA(D_rA),
    .D_rB(D_rB),
    .hlt(hlt),
    .imem_error(imem_error),
    .instr_valid(instr_valid)
  );

  decode decode1( 
    .clk(clk),
    .D_stat(D_stat),
    .D_icode(D_icode),
    .D_ifun(D_ifun),
    .D_valC(D_valC),
    .D_valP(D_valP),
    .D_rA(D_rA),
    .D_rB(D_rB),
    .d_srcA(d_srcA),
    .d_srcB(d_srcB),
    .e_dstE(e_dstE),
    .M_dstE(M_dstE),
    .M_dstM(M_dstM),
    .e_valE(e_valE),
    .M_valE(M_valE),
    .m_valM(m_valM),
    .E_valA(E_valA),
    .E_valB(E_valB),
    .E_srcA(E_srcA),
    .E_srcB(E_srcB),
    .E_icode(E_icode),
    .E_ifun(E_ifun),
    .E_stat(E_stat),
    .E_dstE(E_dstE),
    .E_dstM(E_dstM),
    .E_bubble(E_bubble),
    //write
    
    .W_icode(W_icode),
    .W_dstE(W_dstE),
    .W_dstM(W_dstM),
    .W_valE(W_valE),
    .W_valM(W_valM),
    
    .in_reg0(in_reg0),
    .in_reg1(in_reg1),
    .in_reg2(in_reg2),
    .in_reg3(in_reg3),
    .in_reg4(in_reg4),
    .in_reg5(in_reg5),
    .in_reg6(in_reg6),
    .in_reg7(in_reg7),
    .in_reg8(in_reg8),
    .in_reg9(in_reg9),
    .in_reg10(in_reg10),
    .in_reg11(in_reg11),
    .in_reg12(in_reg12),
    .in_reg13(in_reg13),
    .in_reg14(in_reg14),
    .reg_mem0(reg_mem0),
    .reg_mem1(reg_mem1),
    .reg_mem2(reg_mem2),
    .reg_mem3(reg_mem3),
    .reg_mem4(reg_mem4),
    .reg_mem5(reg_mem5),
    .reg_mem6(reg_mem6),
    .reg_mem7(reg_mem7),
    .reg_mem8(reg_mem8),
    .reg_mem9(reg_mem9),
    .reg_mem10(reg_mem10),
    .reg_mem11(reg_mem11),
    .reg_mem12(reg_mem12),
    .reg_mem13(reg_mem13),
    .reg_mem14(reg_mem14)
   );



pipe_execute execute(  
    .clk(clk),
    .E_stat(E_stat),
    .E_icode(E_icode),
    .E_ifun(E_ifun),
    .E_dstE(E_dstE),
    .E_dstM(E_dstM),
    .E_valA(E_valA),
    .E_valB(E_valB),
    .E_valC(E_valC),
    .set_CC(setCC),
    .W_stat(W_stat),
    .m_stat(m_stat),
    .M_stat(M_stat),
    .M_icode(M_icode),
    .M_Cnd(M_cnd),
    .e_Cnd(e_cnd),
    .M_valE(M_valE),
    .M_valA(M_valA),
    .e_valE(e_valE),
    .M_dstE(M_dstE),
    .M_dstM(M_dstM),
    .e_dstE(e_dstE)


  

);
    
    
pipe_memory memory1(  
  .clk(clk),
.M_stat(M_stat),
.M_icode(M_icode),

.M_valE(M_valE),
.M_valA(M_valA),

.M_dstE(M_dstE),
.M_dstM(M_dstM),


.W_stat(W_stat),
.m_stat(m_stat),

.W_icode(W_icode),
.W_valE(W_valE),
.W_valM(W_valM),
.W_dstE(W_dstE),
.W_dstM(W_dstM),
.m_valM(m_valM)



);




  pipe_control pipe_control(
    .F_stall(F_stall),.D_stall(D_stall),.D_bubble(D_bubble),.E_bubble(E_bubble),.W_stall(W_stall),.set_cc(set_cc),
    .D_icode(D_icode),.d_srcA(d_srcA),.d_srcB(d_srcB),.E_icode(E_icode),.E_dstM(E_dstM),.e_cnd(e_cnd),.M_icode(M_icode),.m_stat(m_stat),.W_stat(W_stat)
    );

//   always @(hlt) begin
//     if(hlt==1) 
     
//   end 



// stopping program based on error flags from stat
// always @(stat)
// begin
//     case (stat)
//         4'b0001:
//         begin
//             $display("Invalid Instruction Encounterd, Stopping!");
//             $finish;
//         end
//         4'b0010:
//         begin
//             $display("Memory Leak Encounterd, Stopping!");
//             $finish;
//         end
//         4'b0100:
//         begin
//             $display("Halt Encounterd, Halting!");
//             $finish;
//         end
//         4'b1000:
//         begin
//             // All OK (No action required)
//         end
//     endcase    
// end

// each instruction ends at writeback stage
// thus the status codes for stopping the program must be seen at the end of each instruction
// that is why the last stage (writeback) is used for checking the status codes
always @(W_stat)
begin
    stat = W_stat;
    if (stat!=4'b1000) begin
         $finish;
    end
    
end


// PC update based on predicted PC at every pos edge
always @(posedge clk)
begin
    if(!F_stall)
    F_predPC = predPC;    
end

initial begin
    $dumpfile("processor.vcd");
    $dumpvars(0,Proc);
    F_predPC = 64'd0;
    clk = 0;
    // $monitor("clk=%d f_predictedPC=%d F_predictedPC=%d D_icode=%d,E_icode=%d, M_icode=%d, ifun=%d,rax=%d,rdx=%d,rbx=%d,rcx=%d\n",clk,f_predictedPC,F_predictedPC, D_icode,E_icode,M_icode,D_ifun,R0,R2,R3,R1);
$monitor("clk=%d\n D_rA:%d D_rB:%d\n predict_PC=%d\n F_predPC=%d\n D_icode=%d\n,E_icode=%d\n, M_icode=%d\n,D_valC=%d\n,E_valA=%d\n,E_valB=%d\n e_valE=%d\n,m_valM=%d\n, e_valE=%d, f_stall=%d, ifun=%d, reg_mem1=%d, reg_mem2=%d, reg_mem3=%d, reg_mem4=%d, reg_mem5=%d, reg_mem6=%d, reg_mem7=%d, reg_mem8=%d, reg_mem9=%d, reg_mem10=%d, reg_mem11=%d, reg_mem12=%d, reg_mem13=%d, reg_mem14=%d, e_valE=%d\n", clk, D_rA,D_rB,predPC, F_predPC, D_icode, E_icode, M_icode, D_valC,E_valA,E_valB,e_valE,m_valM, e_valE,F_stall, D_ifun, reg_mem1, reg_mem2, reg_mem3, reg_mem4, reg_mem5, reg_mem6, reg_mem7, reg_mem8, reg_mem9, reg_mem10, reg_mem11, reg_mem12, reg_mem13, reg_mem14, e_valE);


end


endmodule
