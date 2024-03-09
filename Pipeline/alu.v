`include "./and_64.v"
`include "./xor_64.v"
`include "./add_sub_64.v"

//hi
module alu_block(
    input [63:0] A,
    input [63:0] B,
    input [1:0] S,               //control 2-bit number S
    output reg [63:0] result,
    output reg overflow);

    wire not_S0, not_S1;
    wire enable_add, enable_sub, enable_and, enable_xor;
    wire [63:0] A_add, B_add, A_sub, B_sub, A_xor, B_xor, A_and, B_and;
    wire [63:0] add_result, sub_result, xor_result, and_result;
    wire OF_add, OF_sub;

    not U1(not_S0, S[0]);
    not U2(not_S1, S[1]);

    //assigning the result bits as the outputs of the 2x4 Decoder
    assign U3 = not_S0 & not_S1;
    assign U4 = S[0] & not_S1;
    assign U5 = not_S0 & S[1];
    assign U6 = S[0] & S[1];

    //determining enable signals based on the decoder result
    assign enable_add = (U3 == 1'b1);
    assign enable_sub = (U4 == 1'b1);
    assign enable_xor = (U5 == 1'b1);
    assign enable_and = (U6 == 1'b1);

    //creating enable blocks for each operations
    enable_block add_enable(A, B, enable_add, A_add, B_add);
    enable_block sub_enable(A, B, enable_sub, A_sub, B_sub);
    enable_block xor_enable(A, B, enable_xor, A_xor, B_xor);
    enable_block and_enable(A, B, enable_and, A_and, B_and);

    //performing ALU operations using 64-bit adder/subtractor, comparator, and AND gate
    sixty_four_bit_add_sub adder(A_add, B_add, S[0], add_result, OF_add);
    sixty_four_bit_add_sub subtractor(A_sub, B_sub, S[0], sub_result, OF_sub);
    sixty_four_bit_xor bitwise_xor(A_xor, B_xor, xor_result);
    sixty_four_bit_and bitwise_and(A_and, B_and, and_result);

    //concatenating the results of individual operations
    always @* begin
        if (enable_add) begin
            result = add_result;
            overflow = OF_add;
        end else if (enable_sub) begin
            result = sub_result;
            overflow = OF_sub;
        end else if (enable_and) begin
            result = and_result;
            overflow = 0;
        end else if (enable_xor) begin
            result = xor_result;
            overflow = 0;
        end else begin
            result = 64'b0;
            overflow = 0;
        end
    end
endmodule


module enable_block(
    input [63:0] A,
    input [63:0] B,
    input enable,
    output reg [63:0] new_A,
    output reg [63:0] new_B);

    //defining the new inputs for the ALU operations to be performed
    always @* begin
        if (enable) begin
            new_A = A;
            new_B = B;
        end else begin
            new_A = 64'b0;
            new_B = 64'b0;
        end
    end
endmodule


