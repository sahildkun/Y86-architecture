module pipe_memory (
    input clk,
    input [3:0] M_stat,
    input [3:0] M_icode,
    input [63:0] M_valE, M_valA,
    input [3:0] M_dstE, M_dstM,
    output reg [3:0] W_stat, m_stat,
    output reg [3:0] W_icode,
    output reg [63:0] W_valE, W_valM, m_valM,
    output reg [3:0] W_dstE, W_dstM
);

reg [63:0] memory [0:1023];
reg dmem_error = 1'b0;
reg [3:0] m_icode, m_dstE, m_dstM;
reg [63:0] m_valE;

always @(*) begin
    m_stat = M_stat;
    m_valE = M_valE;
    m_icode = M_icode;
    m_dstE = M_dstE;
    m_dstM = M_dstM;
end

always @(posedge clk) begin
    if(M_valE > 1023 || M_valA > 1023) begin
        $display("Memory bounds exceeded. M_valE:%d, M_valA:%d", M_valE, M_valA);
        assign dmem_error = 1'b1;
    end
    case(M_icode)
        4'b0101:
            m_valM = memory[M_valE];   //'mrmovq'
        4'b1001, 4'b1011:
            m_valM = memory[M_valA];   //'ret' or 'popq'
        4'b0100, 4'b1010, 4'b1000:
            memory[M_valE] = M_valA;   //'rmmovq' or 'pushq' or 'call'   
    endcase
end

always @(*) begin
    if(dmem_error == 1)
        m_stat = 4'b0010;
    else    
        m_stat = M_stat;
end

//setting the values of the write-back register
always @(posedge clk) begin
    W_stat <= m_stat;
    W_icode <= m_icode;
    W_valE <= m_valE;
    W_valM <= m_valM;
    W_dstE <= m_dstE;
    W_dstM <= m_dstM;
end

endmodule
