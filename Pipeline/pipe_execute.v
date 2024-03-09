    `include "./alu.v"

module pipe_execute (
    input clk,
    input [3:0] E_stat, E_icode, E_ifun, E_dstE, E_dstM,
    input [63:0] E_valA, E_valB, E_valC,
    input set_CC,
    input [3:0] W_stat, m_stat,

    output reg [3:0] M_stat, M_icode,
    output reg M_Cnd, e_Cnd,
    output reg [63:0] M_valE, M_valA, e_valE,
    output reg [3:0] M_dstE, M_dstM, e_dstE
);

//assigning the condition flags and initializing them to zero
reg [2:0] outCC;
initial begin
    outCC[0] = 0;
    outCC[1] = 0;
    outCC[2] = 0;
end

wire zeroflag, signedflag, overflowflag;

always @(*) begin
    if (set_CC) begin
        outCC[2] = overflowflag;
        outCC[1] = e_valE[63];
        outCC[0] = (e_valE == 0) ? 1'b1 : 1'b0;
    end
end

wire [63:0] result_BC, result_add, result_and, result_sub, result_xor, result_IN, result_DE;
wire overflow1, overflow2, overflow3, overflow_add, overflow_and, overflow_sub, overflow_xor;

//instantiating the ALU blocks
alu_block alu_int1(.A(E_valB), .B(E_valC), .S(2'b00), .result(result_BC), .overflow(overflow1));      //used in the calculation of mrmovq & rmmovq
alu_block alu_int3(.A(E_valB), .B(64'b1000), .S(2'b00), .result(result_IN), .overflow(overflow2));    //used in the calculation of 'increasing the stack pointer', i.e., popq
alu_block alu_int4(.A(E_valB), .B(64'b1000), .S(2'b01), .result(result_DE), .overflow(overflow3));    //used in the calculation of 'decreasing the stack pointer', i.e., pushq

alu_block alu_add(.A(E_valA), .B(E_valB), .S(2'b00), .result(result_add), .overflow(overflow_add));
alu_block alu_sub(.A(E_valB), .B(E_valA), .S(2'b01), .result(result_sub), .overflow(overflow_sub));
alu_block alu_and(.A(E_valA), .B(E_valB), .S(2'b10), .result(result_and), .overflow(overflow_and));
alu_block alu_xor(.A(E_valA), .B(E_valB), .S(2'b11), .result(result_xor), .overflow(overflow_xor));


always @(*) begin
    case (E_icode)
        4'b0010: e_valE = E_valA;                 //cmovq
        4'b0011: e_valE = E_valC;                 //irmovq
        4'b0100: e_valE = result_BC;              //rmmovq
        4'b0101: e_valE = result_BC;              //mrmovq
        4'b0110: begin                        
                     case (E_ifun)
                        4'b0000: begin
                            e_valE = result_add;
                            outCC[2] = overflow_add;
                            outCC[1] = e_valE[63];
                            outCC[0] = (e_valE == 0) ? 1'b1 : 1'b0;
                        end
                        4'b0001: begin
                            e_valE = result_sub;
                            outCC[2] = overflow_sub;
                            outCC[1] = e_valE[63];
                            outCC[0] = (e_valE == 0) ? 1'b1 : 1'b0;
                        end
                        4'b0010: begin
                            e_valE = result_xor;
                            outCC[2] = overflow_xor;
                            outCC[1] = e_valE[63];
                            outCC[0] = (e_valE == 0) ? 1'b1 : 1'b0;
                        end
                        4'b0011: begin
                            e_valE = result_and;
                            outCC[2] = overflow_and;
                            outCC[1] = e_valE[63];
                            outCC[0] = (e_valE == 0) ? 1'b1 : 1'b0;
                        end
                    endcase
                end                             //OPq
        4'b1000: e_valE = result_DE;            //call
        4'b1001: e_valE = result_IN;            //ret
        4'b1010: e_valE = result_DE;            //pushq
        4'b1011: e_valE = result_IN;            //popq
        default: begin
                    e_valE = 64'd0;             //assigning a default value for M_valE
                    outCC = 3'b000;             //assigning a default value for outCC
                end
    endcase
end


assign zeroflag = outCC[0];
assign signedflag = outCC[1];
assign overflowflag = outCC[2];


always @(*) begin
    if (E_icode == 4'b0010 || E_icode == 4'b0111) begin  //for CMOVXX and JUMP
        case (E_ifun)
            4'b0000: e_Cnd = 1;                                           //unconditional
            4'b0001: e_Cnd = (overflowflag^signedflag) | zeroflag;        //less than or equal to
            4'b0010: e_Cnd = (overflowflag^signedflag);                   //less than only
            4'b0011: e_Cnd = zeroflag;                                    //equal to
            4'b0100: e_Cnd = ~zeroflag;                                   //not equal to
            4'b0101: e_Cnd = ~(overflowflag^signedflag);                  //greater than or equal to
            4'b0110: e_Cnd = ~(overflowflag^signedflag) & ~zeroflag;      //greater than only
        endcase
    end
end

always @(*) begin
    if (E_icode == 4'b0010 || E_icode == 4'b0111) begin
        e_dstE = (e_Cnd == 1) ? E_dstE : 4'b1111;        //empty register
    end else begin
        e_dstE = E_dstE;
    end
end

//assigning the values that are supposed to go into the M register. Also, M_bubble is not considered. If considered
//we need nop
always @(posedge clk) begin
    M_stat <= E_stat;
    M_icode <= E_icode;
    M_Cnd <= e_Cnd;
    M_valE <= e_valE;
    M_valA <= E_valA;
    M_dstE <= e_dstE;
    M_dstM <= E_dstM;
end

endmodule