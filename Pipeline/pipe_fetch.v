module fetch(
    
input clk,



input F_stall, D_stall, D_bubble, M_cnd, // stall and bubble and cnd flags
input [3:0] M_icode, W_icode,// used for checking misprediction of branch
input [63:0] M_valA, W_valM, F_predPC, // used for checking misprediction of branch and input predicted pc


  

output  reg [63:0] predPC,


output reg [3:0] D_icode, D_ifun, D_rA, D_rB,       // pipe registers in decode
output reg [63:0] D_valC, D_valP,       // pipe registers in decode
output reg [3:0] D_stat, 
output reg imem_error,
output reg instr_valid,
                    // status code for decode stage: AllOK, Halt, Adr_error, Instruction_error

output reg hlt
);

// reg [3:0]icode,f_ifun,f_rA,f_rB;
// reg [63:0] f_valC, f_predict_pc;

reg [7:0] instruction_memory[0:1023];
reg [63:0] PC;
reg [3:0] icode;
reg [3:0] ifun;

reg [3:0] rA;

reg [3:0] rB;

reg [63:0] valC;
reg [63:0] valP;

reg [3:0] f_stat;

reg[0:79] instruction;

initial begin
    // irmovq $0x100, %rbx
    instruction_memory[0] = 8'b00110000;//3 0
    instruction_memory[1] = 8'b11110011;//ra rb
    instruction_memory[2] = 8'b00000000;
    instruction_memory[3] = 8'b00000001;
    instruction_memory[4] = 8'b00000000;
    instruction_memory[5] = 8'b00000000;
    instruction_memory[6] = 8'b00000000;
    instruction_memory[7] = 8'b00000000;
    instruction_memory[8] = 8'b00000000;
    instruction_memory[9] = 8'b00000000;

    // irmovq $0x200, %rdx
    instruction_memory[10] = 8'b00110000;
    instruction_memory[11] = 8'b10010010;
    instruction_memory[12] = 8'b00000000;
    instruction_memory[13] = 8'b00000010;
    instruction_memory[14] = 8'b00000000;
    instruction_memory[15] = 8'b00000000;
    instruction_memory[16] = 8'b00000000;
    instruction_memory[17] = 8'b00000000;
    instruction_memory[18] = 8'b00000000;
    instruction_memory[19] = 8'b00000000;

    // addq %rdx, %rbx
    instruction_memory[20] = 8'b01100000;//6 0
    instruction_memory[21] = 8'b00100011;//2 3
    instruction_memory[22] = 8'b00000000;
    instruction_memory[23] = 8'b00000000;
    instruction_memory[24] = 8'b00000000;
    instruction_memory[25] = 8'b00000000;
    instruction_memory[26] = 8'b00000000;
    instruction_memory[27] = 8'b00000000;
    instruction_memory[28] = 8'b00000000;
    instruction_memory[29] = 8'b00000000;

     //halt
    instruction_memory[30]=8'b00000000; //
end
  



always @(PC) begin
       instruction = {instruction_memory[PC],
                    instruction_memory[PC+1],
                    instruction_memory[PC+2],
                    instruction_memory[PC+3],
                    instruction_memory[PC+4],
                    instruction_memory[PC+5],
                    instruction_memory[PC+6],
                    instruction_memory[PC+7],
                    instruction_memory[PC+8],
                    instruction_memory[PC+9]
                    };

    icode = instruction[0:3]; // first 4 bytes are icode
    ifun = instruction[4:7]; // next 4 bytes are i fun
end

    



always @(*)begin
        
         imem_error = 1'b0;
          instr_valid=1'b1;

        if (hlt)
        begin 
            // hlt
            f_stat[0] = 1'b0;
            f_stat[1] = 1'b0;
            f_stat[2] = 1'b0; 
            f_stat[3] = 1'b1; // not AOK
        end
        if (PC > 1023)
        begin 
            // mem error (ADR)
            f_stat[0] = 1'b0;
            f_stat[1] = 1'b1;
            f_stat[2] = 1'b0; 
            f_stat[3] = 1'b0; // not AOK 
            imem_error = 1'b1;
        end
        if (!instr_valid)
        begin
            f_stat[0] = 1'b0; // not AOK
            f_stat[1] = 1'b0; //no HLT
            f_stat[2] = 1'b1; 
            f_stat[3] =1'b0;//no mem, inst error. (INS/ADR)
        end
        else 
        begin
            f_stat[0] = 1'b1; // AOK
            f_stat[1] = 1'b0; //no HLT
            f_stat[2] = 1'b0; 
            f_stat[3] =1'b0;//no mem, inst error. (INS/ADR)
        end

      
end

// finding rA, rB, valC, valP, and predPC
always @(*)
begin
    if(icode==4'h0)
    begin
        valP = PC;
        predPC=valP;
        hlt=1;
    end
    else if (icode==4'h1)           // nop instruction
    begin
        valP = PC+1;
        predPC = valP;
    end
    else if (icode==4'h3)           // irmovq V, rB
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valC={instruction_memory[PC+9],instruction_memory[PC+8],instruction_memory[PC+7],
                instruction_memory[PC+6],instruction_memory[PC+5],instruction_memory[PC+4],instruction_memory[PC+3],instruction_memory[PC+2]};
        valP = PC+10;
        predPC = valP;
    end
    else if (icode==4'h4)           // rmmovq rA, D(rB)
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valC = instruction[16:79];
        valP = PC+10;
        predPC = valP;
    end
    else if (icode==4'h5)           // mrmovq D(rB), rA
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valC = instruction[16:79];
        valP = PC+10;
        predPC = valP;
    end
    else if (icode==4'h2)           // cmovxx rA, rB
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valP = PC+2;
        predPC = valP;
    end
    else if (icode==4'h6)           // OPq rA, rB
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valP = PC+2;
        predPC = valP;
    end
    else if (icode==4'hA)           // pushq rA
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valP = PC+2;
        predPC = valP;
    end
    else if (icode==4'hB)           // popq rA
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valP = PC+2;
        predPC = valP;
    end
    else if (icode==4'h7)           // jXX Dest
    begin
        valC = instruction[8:71];
        valP = PC+9;
        predPC = valC; // assuming that the jump is taken (true with ~0.6 probability)
    end
    else if (icode==4'h8)           // call Dest
    begin
        valC = instruction[8:71];
        valP = PC+9;
        predPC = valC; 
    end
    else if (icode==4'h9)           // ret
    begin
        valP = PC+1;
        // no prediction of PC as ret could go anywhere
    end
    else
    begin                           // no valid instruction passed
        instr_valid=1'b0;
    end
end



initial
begin
    PC = F_predPC; // PC is just the predicted PC as of now (next instruction PC)
end



always @(*)
 begin
    // handling PC according to jump and ret
    if(W_icode==4'b1001)
        PC = W_valM;            // getting return PC value from WriteBack (PC gets updated and pipe is unstalled)
    else if(M_icode==4'b0111 & !M_cnd)
        PC = M_valA;            // misprediction of branch
    else
        PC = F_predPC;     // else PC is just the fall through PC
    
end

always @(posedge clk ) 
begin
    if (F_stall==1'b1)
    begin
        PC = F_predPC;   
        // $display("condition 1");
    end
    
    if (D_stall==1'b0 & D_bubble==1'b1)
    begin
        // $display("condition 2");
        // inserting a bubble (nop instruction) 
        D_icode <= 4'h1;
        D_ifun <= 4'h0;
        D_rA <= 4'hF;
        D_rB <= 4'hF;
        D_valC <= 64'b0;
        D_valP <= 64'b0;
        D_stat <= 4'h8;
    end
    else if (!D_stall)
    begin
        // $display("condition 3, here D_icode = %b",D_icode);
        // passing the instruction values as it is to the next stage
        D_icode <= icode;
        D_ifun <= ifun;
        D_rA <= rA;
        D_rB <= rB;
        D_valC <= valC;
        D_valP <= valP;
        D_stat <= f_stat;
    end

end

endmodule