module sixty_four_bit_add_sub (
    input [63:0] A,
    input [63:0] B,
    input m,
    output [63:0] Sum,
    output Overflow);

    wire [63:0] temp_sum;
    wire [64:0] c_temp;

    assign c_temp[0] = m;

    genvar i;
    generate
        for (i=0; i<64; i=i+1) begin
            full_adder fa(
                .a(A[i]), .b(B[i] ^ m), .c_in(c_temp[i]), .sum(temp_sum[i]), .carry(c_temp[i+1]));
        end
    endgenerate

    assign Sum = temp_sum;
    assign Overflow = c_temp[63] ^ c_temp[64]; //overflow is the XOR of the last two carry bits
endmodule


module full_adder(
    //defining the inputs and outputs of the 
    input a,
    input b,
    input c_in,
    output sum,
    output carry);

    wire w1,c1,c2,c3;

    xor (w1,a,b);              //'sum' is equivalent to the Ex-OR operation performed on the three
    xor (sum,w1,c_in);         //inputs; a,b and c_in
    
    /*initial begin
        $display("sum = %b", sum);
    end*/

    and (c1,a,b);
    and (c2,b,c_in);             
    and (c3,a,c_in);

    or (carry,c1,c2,c3);       //this gives us the output 'carry' that is equivalent to the sum
                               //of the three a and b, b and c_in and a and c_in

endmodule