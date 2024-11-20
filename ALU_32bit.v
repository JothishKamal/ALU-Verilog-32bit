`include "FPU.v"

module ALU_32bit(
    input [31:0] A, B,            // 32-bit inputs A and B
    input [3:0] ALU_Sel,          // 4-bit ALU selection input
    output reg [31:0] ALU_Out,    // 32-bit ALU output
    output Zero                   // Zero flag output
);

    // Interpret A and B as signed integers for signed operations
    wire signed [31:0] signed_A = A;
    wire signed [31:0] signed_B = B;

    // Wires for floating-point operation results
    wire [31:0] fp_mul_result;
    wire [31:0] fp_div_result;

    // Instantiate the floating-point multiplier
    fp_mul fp_multiplier (
        .A(A),
        .B(B),
        .Result(fp_mul_result)
    );

    // Instantiate the floating-point divider
    fp_div fp_divider (
        .A(A),
        .B(B),
        .Result(fp_div_result)
    );

    // ALU operation based on ALU_Sel input
    always @(*) begin
        case(ALU_Sel)
            4'b0000: ALU_Out = A + B;                    // Unsigned Addition
            4'b0001: ALU_Out = A - B;                    // Unsigned Subtraction
            4'b0010: ALU_Out = A * B;                    // Unsigned Multiplication
            4'b0011: ALU_Out = (B != 0) ? (A / B) : 32'b0; // Unsigned Division with zero check
            4'b0100: ALU_Out = signed_A + signed_B;      // Signed Addition
            4'b0101: ALU_Out = signed_A - signed_B;      // Signed Subtraction
            4'b0110: ALU_Out = signed_A * signed_B;      // Signed Multiplication
            4'b0111: begin                               // Signed Division with zero check
                if (signed_B != 0) begin
                    ALU_Out = signed_A / signed_B;
                end else begin
                    ALU_Out = 32'b0;                    // Division by zero yields zero
                end
            end
            4'b1000: ALU_Out = (signed_A < signed_B) ? 32'b1 : 32'b0;   // Less Than
            4'b1001: ALU_Out = (signed_A <= signed_B) ? 32'b1 : 32'b0;  // Less Than or Equal
            4'b1010: ALU_Out = (signed_A > signed_B) ? 32'b1 : 32'b0;   // Greater Than
            4'b1011: ALU_Out = (signed_A >= signed_B) ? 32'b1 : 32'b0;  // Greater Than or Equal
            4'b1100: ALU_Out = (A == B) ? 32'b1 : 32'b0;                // Equal
            4'b1101: ALU_Out = (A != B) ? 32'b1 : 32'b0;                // Not Equal
            4'b1110: ALU_Out = fp_mul_result;                           // Floating-Point Multiplication
            4'b1111: ALU_Out = fp_div_result;                           // Floating-Point Division
            default: ALU_Out = 32'b0;                                   // Default case
        endcase
    end

    // Zero flag is high if ALU_Out is zero
    assign Zero = (ALU_Out == 32'b0) ? 1'b1 : 1'b0;

endmodule
