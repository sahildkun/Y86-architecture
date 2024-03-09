module sixty_four_bit_and (
    input [63:0] A,
    input [63:0] B,
    output [63:0] Result);

    wire [63:0] w;

    genvar i;
    generate
        for(i=0;i<64;i=i+1) begin
            bitwise_and andi (.a(A[i]), .b(B[i]), .out(w[i]));
        end
    endgenerate

    assign Result = w;

endmodule


//defining the bitwise_and module
module bitwise_and (
    input a,
    input b,
    output out);

    and(out,a,b);

endmodule
