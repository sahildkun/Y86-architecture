module sixty_four_bit_xor(
    input [63:0] A,
    input [63:0] B,
    output [63:0] Result);

    wire [63:0] temp;

    genvar i;
    generate
        for(i=0;i<64;i=i+1) begin
            bitwise_xor xori(.a(A[i]), .b(B[i]), .out(temp[i]));
        end
    endgenerate

    assign Result = temp;

endmodule


//defining the bitwise xor module
module bitwise_xor(
    input a,
    input b,
    output out);

    wire not_a, not_b, w1, w2;

    not(not_a,a);
    not(not_b,b);

    and(w1,a,not_b);
    and(w2,not_a,b);
    or(out,w1,w2);

endmodule