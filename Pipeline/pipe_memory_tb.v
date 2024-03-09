`timescale 1ns / 1ps

module pipe_memory_tb;

    reg clk;
    reg [3:0] M_stat;
    reg [3:0] M_icode;
    reg [63:0] M_valE, M_valA;
    reg [3:0] M_dstE, M_dstM;
    
    // Outputs
    wire [3:0] W_stat, m_stat;
    wire [3:0] W_icode;
    wire [63:0] W_valE, W_valM, m_valM;
    wire [3:0] W_dstE, W_dstM;

    //instantiating the pipe_memory module
    pipe_memory pipe_memory_inst (
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
        .m_valM(m_valM),
        .W_dstE(W_dstE),
        .W_dstM(W_dstM)
    );

    always #5 clk = ~clk;

    initial begin
        //initializing the inputs
        clk = 0;
        M_stat = 3'b000;
        M_icode = 4'b0000;
        M_valE = 64'h0000000000000000;
        M_valA = 64'h0000000000000000;
        M_dstE = 4'b0000;
        M_dstM = 4'b0000;

        #10;
        
        //Test Case 1: Valid Memory Operation - mrmovq
        M_icode = 4'b0101;  //mrmovq
        M_valE = 10;
        #10;
        $display("Test Case 1:");
        $display("Input: M_stat=%b, M_icode=%b, M_valE=%d, M_valA=%d, M_dstE=%b, M_dstM=%b", M_stat, M_icode, M_valE, M_valA, M_dstE, M_dstM);
        $display("Output: W_stat=%b, m_stat=%b, W_icode=%b, W_valE=%d, W_valM=%d, m_valM=%d, W_dstE=%b, W_dstM=%b", W_stat, m_stat, W_icode, W_valE, W_valM, m_valM, W_dstE, W_dstM);
        
        //Test Case 2: Valid Memory Operation - ret
        M_icode = 4'b1001;  //ret
        M_valA = 20;
        #10;
        $display("\nTest Case 2:");
        $display("Input: M_stat=%b, M_icode=%b, M_valE=%d, M_valA=%d, M_dstE=%b, M_dstM=%b", M_stat, M_icode, M_valE, M_valA, M_dstE, M_dstM);
        $display("Output: W_stat=%b, m_stat=%b, W_icode=%b, W_valE=%d, W_valM=%d, m_valM=%d, W_dstE=%b, W_dstM=%b", W_stat, m_stat, W_icode, W_valE, W_valM, m_valM, W_dstE, W_dstM);

        //Test Case 3: Valid Memory Operation - popq
        M_icode = 4'b1011;  //popq
        M_valA = 30;
        #10;
        $display("\nTest Case 3:");
        $display("Input: M_stat=%b, M_icode=%b, M_valE=%d, M_valA=%d, M_dstE=%b, M_dstM=%b", M_stat, M_icode, M_valE, M_valA, M_dstE, M_dstM);
        $display("Output: W_stat=%b, m_stat=%b, W_icode=%b, W_valE=%d, W_valM=%d, m_valM=%d, W_dstE=%b, W_dstM=%b", W_stat, m_stat, W_icode, W_valE, W_valM, m_valM, W_dstE, W_dstM);
        
        //Test Case 4: Memory Bound Error - Exceeds memory size
        M_icode = 4'b0101;  //mrmovq
        M_valE = 1050; // Exceeds memory size
        #10;
        $display("\nTest Case 4:");
        $display("Input: M_stat=%b, M_icode=%b, M_valE=%d, M_valA=%d, M_dstE=%b, M_dstM=%b", M_stat, M_icode, M_valE, M_valA, M_dstE, M_dstM);
        $display("Output: W_stat=%b, m_stat=%b, W_icode=%b, W_valE=%d, W_valM=%d, m_valM=%d, W_dstE=%b, W_dstM=%b", W_stat, m_stat, W_icode, W_valE, W_valM, m_valM, W_dstE, W_dstM);
        
        // Add more test cases as needed
        
        $finish;
    end

endmodule
