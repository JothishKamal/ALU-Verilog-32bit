module fp_mul (
    input [31:0] A,  // Input floating point number A
    input [31:0] B,  // Input floating point number B
    output [31:0] Result // Output floating point result
);

    wire sign;
    wire [7:0] exp_A, exp_B, exp_sum;
    wire [23:0] mant_A, mant_B;
    wire [47:0] product;
    wire [7:0] final_exp;
    wire [23:0] final_mantissa;
    wire normalized;

    // Calculate the sign of the result (XOR of input signs)
    assign sign = A[31] ^ B[31];

    // Extract exponents from inputs
    assign exp_A = A[30:23];
    assign exp_B = B[30:23];

    // Extract mantissas and add implicit leading 1
    assign mant_A = {1'b1, A[22:0]};
    assign mant_B = {1'b1, B[22:0]};

    // Sum the exponents and adjust for bias
    assign exp_sum = exp_A + exp_B - 8'd127;

    // Multiply the mantissas
    assign product = mant_A * mant_B;

    // Check if normalization is needed
    assign normalized = product[47];

    // Adjust exponent if product is normalized
    assign final_exp = normalized ? exp_sum + 1 : exp_sum;

    // Select appropriate mantissa bits based on normalization
    assign final_mantissa = normalized ? product[46:24] : product[45:23];

    // Detect special cases
    wire is_zero_A = (A[30:0] == 31'b0);
    wire is_zero_B = (B[30:0] == 31'b0);
    wire is_inf_A = (exp_A == 8'hFF) && (A[22:0] == 0);
    wire is_inf_B = (exp_B == 8'hFF) && (B[22:0] == 0);
    wire is_nan_A = (exp_A == 8'hFF) && (A[22:0] != 0);
    wire is_nan_B = (exp_B == 8'hFF) && (B[22:0] != 0);

    // Check for infinity multiplied by zero
    wire inf_times_zero = (is_inf_A && is_zero_B) || (is_inf_B && is_zero_A);

    // Define local parameters for special IEEE 754 values
    localparam NAN = 32'h7FC00000;   // Not a Number
    localparam ZERO = 32'h00000000;  // Zero
    localparam INF = 32'h7F800000;   // Infinity

    // Determine the final result
    assign Result = (is_nan_A || is_nan_B || inf_times_zero) ? NAN : // NaN
                    (is_inf_A || is_inf_B) ? INF : // Infinity
                    (is_zero_A || is_zero_B) ? ZERO : // Zero
                    {sign, final_exp, final_mantissa[22:0]}; // Normalized result
endmodule

module fp_div (
    input [31:0] A, B,        // 32-bit floating-point inputs A and B
    output reg [31:0] Result  // 32-bit floating-point output Result
);

    // Check if A is zero (exponent and mantissa are zero)
    wire a_is_zero = (A[30:23] == 8'h00) && (A[22:0] == 23'h0);
    // Check if B is zero
    wire b_is_zero = (B[30:23] == 8'h00) && (B[22:0] == 23'h0);
    // Check if A is infinity (exponent is all ones and mantissa is zero)
    wire a_is_inf = (A[30:23] == 8'hFF) && (A[22:0] == 23'h0);
    // Check if B is infinity
    wire b_is_inf = (B[30:23] == 8'hFF) && (B[22:0] == 23'h0);
    // Check if A is NaN (exponent is all ones and mantissa is non-zero)
    wire a_is_nan = (A[30:23] == 8'hFF) && (A[22:0] != 23'h0);
    // Check if B is NaN
    wire b_is_nan = (B[30:23] == 8'hFF) && (B[22:0] != 23'h0);

    // Extract sign bits of A and B
    wire sign_A = A[31];
    wire sign_B = B[31];
    // Extract exponent bits of A and B
    wire [7:0] exp_A = A[30:23];
    wire [7:0] exp_B = B[30:23];
    // Extract mantissa bits of A and B and add the implicit leading 1
    wire [23:0] mant_A = {1'b1, A[22:0]};
    wire [23:0] mant_B = {1'b1, B[22:0]};
    
    // Calculate the sign of the result (XOR of input signs)
    wire sign_Result = sign_A ^ sign_B;
    // Perform mantissa division with alignment (shift mant_A left by 23 for alignment)
    wire [47:0] mant_Quotient = (mant_A << 23) / mant_B;
    // Calculate the exponent of the result with bias adjustment
    wire [7:0] exp_Result = exp_A - exp_B + 8'd127;
    // Normalize the mantissa (select bits based on most significant bit)
    wire [22:0] final_mant = mant_Quotient[23] ? mant_Quotient[22:0] : mant_Quotient[21:0];

    // Define local parameters for special IEEE 754 values
    localparam NAN = 32'h7FC00000;   // Not a Number
    localparam ZERO = 32'h00000000;  // Zero
    localparam INF = 32'h7F800000;   // Infinity

    // Always block to compute the final result based on special cases and normal computation
    always @(*) begin
        if (a_is_nan || b_is_nan) 
            // If either A or B is NaN, the result is NaN
            Result = NAN;
        else if (a_is_inf && b_is_inf) 
            // Infinity divided by infinity is NaN
            Result = NAN;
        else if (a_is_zero && b_is_zero) 
            // Zero divided by zero is NaN
            Result = NAN;
        else if (a_is_zero && b_is_inf) 
            // Zero divided by infinity is zero
            Result = NAN;
        else if (a_is_inf && b_is_zero) 
            // Infinity divided by zero is NaN
            Result = NAN;
        else if (a_is_zero)
            // Zero divided by any finite number is zero
            Result = ZERO;
        else if (b_is_zero)
            // Division by zero results in infinity with the correct sign
            Result = INF;
        else if (a_is_inf)
            // Infinity divided by any finite number is infinity
            Result = INF;
        else if (b_is_inf) 
            // Any finite number divided by infinity is zero
            Result = ZERO;
        else
            // Normal division result with calculated sign, exponent, and mantissa
            Result = {sign_Result, exp_Result, final_mant};
    end
endmodule
