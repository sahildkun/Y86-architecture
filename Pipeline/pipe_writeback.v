module pipe_writeback(
    input clk,
    input [3:0] W_stat,
    input [3:0] W_icode, W_dstE, W_dstM,
    input [63:0] in_reg0,in_reg1,in_reg2,in_reg3,in_reg4,in_reg5,in_reg6,in_reg7,in_reg8,in_reg9,in_reg10,in_reg11,in_reg12,in_reg13,in_reg14,
    input [63:0] W_valE, W_valM,
    output reg [3:0] w_stat,
    output reg [63:0] reg_mem0,reg_mem1,reg_mem2,reg_mem3,reg_mem4,reg_mem5,reg_mem6,reg_mem7,reg_mem8,reg_mem9,reg_mem10,reg_mem11,reg_mem12,reg_mem13,reg_mem14
);

    reg [63:0] register_file[0:14];

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
