`timescale 1ns/1ps

module pipe_execute_tb();

    // Inputs
    reg clk;
    reg [3:0] E_stat, E_icode, E_ifun, E_dstE, E_dstM;
    reg [63:0] E_valA, E_valB, E_valC;
    reg set_CC;
    reg [3:0] W_stat, m_stat;

    // Outputs
    wire [3:0] M_stat, M_icode;
    wire M_Cnd, e_Cnd;
    wire [63:0] M_valE, M_valA, e_valE;
    wire [3:0] M_dstE, M_dstM, e_dstE;

    // Instantiate the module to be tested
    pipe_execute uut(
        .clk(clk),
        .E_stat(E_stat),
        .E_icode(E_icode),
        .E_ifun(E_ifun),
        .E_dstE(E_dstE),
        .E_dstM(E_dstM),
        .E_valA(E_valA),
        .E_valB(E_valB),
        .E_valC(E_valC),
        .set_CC(set_CC),
        .W_stat(W_stat),
        .m_stat(m_stat),
        .M_stat(M_stat),
        .M_icode(M_icode),
        .M_Cnd(M_Cnd),
        .e_Cnd(e_Cnd),
        .M_valE(M_valE),
        .M_valA(M_valA),
        .e_valE(e_valE),
        .M_dstE(M_dstE),
        .M_dstM(M_dstM),
        .e_dstE(e_dstE)
    );

    // Clock generation
    always begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end

    // Stimulus
    initial begin
        // Initialize inputs
        E_stat = 4'b0000;
        E_icode = 4'b0000;
        E_ifun = 4'b0000;
        E_dstE = 4'b0000;
        E_dstM = 4'b0000;
        E_valA = 64'b0;
        E_valB = 64'b0;
        E_valC = 64'b0;
        set_CC = 1;
        W_stat = 4'b0000;
        m_stat = 4'b0000;

        // Wait a few clock cycles for stability
        #10;

        // Apply test vectors
 // Wait for a few clock cycles for the operation to complete
        // Example: Test cmovq instruction
        E_icode = 4'b0010;
        E_valA = 64'd42; // Sample value for E_valA
        // You can continue setting other inputs and verify the outputs accordingly
        
        #10;

        // Print outputs
        $display("M_stat = %b", M_stat);
        $display("M_icode = %b", M_icode);
        $display("M_Cnd = %b", M_Cnd);
        $display("e_Cnd = %b", e_Cnd);
        $display("M_valE = %d", M_valE);
        $display("M_valA = %d", M_valA);
        $display("e_valE = %d", e_valE);
        $display("M_dstE = %b", M_dstE);
        $display("M_dstM = %b", M_dstM);
        $display("e_dstE = %b", e_dstE);


        E_icode = 4'b0110;   // Set E_icode for the OPq operation
        E_ifun = 4'b0000;    // Set E_ifun for addition operation
        E_valA = 64'd10;     // Sample value for E_valA
        E_valB = 64'd20;     // Sample value for E_valB

        #10;

        $display("Testcase-2 ");
        // Print outputs after addition operation
        $display("M_stat = %b", M_stat);
        $display("M_icode = %b", M_icode);
        $display("M_Cnd = %b", M_Cnd);
        $display("e_Cnd = %b", e_Cnd);
        $display("M_valE = %d", M_valE);  // This should display the result of 10 + 20
        $display("M_valA = %d", M_valA);  // This should display the value of E_valA (10)
        $display("e_valE = %d", e_valE);  // This should also display the result of 10 + 20
        $display("M_dstE = %b", M_dstE);
        $display("M_dstM = %b", M_dstM);
        $display("e_dstE = %b", e_dstE);
        // Finish simulation
        $finish;
    end

endmodule
