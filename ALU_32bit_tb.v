`include "ALU_32bit.v"

module ALU_32bit_tb;
    reg [31:0] A, B;          // Test inputs
    reg [3:0] ALU_Sel;        // Test operation selector
    wire [31:0] ALU_Out;      // Output from ALU
    wire Zero;                // Zero flag from ALU

    // Instantiate the ALU module
    ALU_32bit uut (
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .ALU_Out(ALU_Out),
        .Zero(Zero)
    );

    initial begin
        // Unsigned Addition Test
        A = 32'd10; B = 32'd20; ALU_Sel = 4'b0000;
        #10;
        $display("Unsigned Add: %d + %d = %d (Zero=%b)", A, B, ALU_Out, Zero);

        // Unsigned Subtraction Test
        A = 32'd50; B = 32'd20; ALU_Sel = 4'b0001;
        #10;
        $display("Unsigned Sub: %d - %d = %d (Zero=%b)", A, B, ALU_Out, Zero);

        // Unsigned Multiplication Test
        A = 32'd7; B = 32'd3; ALU_Sel = 4'b0010;
        #10;
        $display("Unsigned Mul: %d * %d = %d (Zero=%b)", A, B, ALU_Out, Zero);

        // Unsigned Division Test
        A = 32'd100; B = 32'd4; ALU_Sel = 4'b0011;
        #10;
        $display("Unsigned Div: %d / %d = %d (Zero=%b)", A, B, ALU_Out, Zero);

        // Signed Addition Test
        A = -25; B = 32'd10; ALU_Sel = 4'b0100;
        #10;
        $display("Signed Add: %d + %d = %d (Zero=%b)", $signed(A), $signed(B), $signed(ALU_Out), Zero);

        // Signed Subtraction Test
        A = -25; B = 32'd10; ALU_Sel = 4'b0101;
        #10;
        $display("Signed Sub: %d - %d = %d (Zero=%b)", $signed(A), $signed(B), $signed(ALU_Out), Zero);

        // Signed Multiplication Test
        A = -5; B = 32'd6; ALU_Sel = 4'b0110;
        #10;
        $display("Signed Mul: %d * %d = %d (Zero=%b)", $signed(A), $signed(B), $signed(ALU_Out), Zero);

        // Signed Division Test
        A = -20; B = -4; ALU_Sel = 4'b0111;
        #10;
        $display("Signed Div: %d / %d = %d (Zero=%b)", $signed(A), $signed(B), $signed(ALU_Out), Zero);

        // Less Than Test
        A = 32'd10; B = 32'd20; ALU_Sel = 4'b1000;
        #10;
        $display("Less Than: %d < %d = %d (Zero=%b)", $signed(A), $signed(B), ALU_Out, Zero);

        // Less Than or Equal Test
        A = 32'd10; B = 32'd20; ALU_Sel = 4'b1001;
        #10;
        $display("Less Equal: %d <= %d = %d (Zero=%b)", $signed(A), $signed(B), ALU_Out, Zero);

        // Greater Than Test
        A = 32'd30; B = 32'd20; ALU_Sel = 4'b1010;
        #10;
        $display("Greater Than: %d > %d = %d (Zero=%b)", $signed(A), $signed(B), ALU_Out, Zero);

        // Greater Than or Equal Test
        A = 32'd30; B = 32'd20; ALU_Sel = 4'b1011;
        #10;
        $display("Greater Equal: %d >= %d = %d (Zero=%b)", $signed(A), $signed(B), ALU_Out, Zero);

        // Equal Test
        A = 32'd20; B = 32'd20; ALU_Sel = 4'b1100;
        #10;
        $display("Equal: %d == %d = %d (Zero=%b)", $signed(A), $signed(B), ALU_Out, Zero);

        // Not Equal Test
        A = 32'd20; B = 32'd15; ALU_Sel = 4'b1101;
        #10;
        $display("Not Equal: %d != %d = %d (Zero=%b)", $signed(A), $signed(B), ALU_Out, Zero);

        // Floating-Point Multiplication Test
        A = 32'h40200000; // 2.5 in IEEE 754
        B = 32'h40800000; // 4.0 in IEEE 754
        ALU_Sel = 4'b1110;
        #10;
        $display("FP Mul: %f * %f = %f (Zero=%b)", 
            $bitstoshortreal(A), $bitstoshortreal(B), $bitstoshortreal(ALU_Out), Zero);

        // Floating-Point Division Test
        A = 32'h41700000; // 15.0 in IEEE 754
        B = 32'h40400000; // 3.0 in IEEE 754
        ALU_Sel = 4'b1111;
        #10;
        $display("FP Div: %f / %f = %f (Zero=%b)", 
            $bitstoshortreal(A), $bitstoshortreal(B), $bitstoshortreal(ALU_Out), Zero);

        // Floating-Point Special Cases
        // Infinity times zero
        A = 32'h7F800000; // Infinity
        B = 32'h00000000; // Zero
        ALU_Sel = 4'b1110;
        #10;
        $display("FP Mul Special: Inf * 0 = %h (Zero=%b)", ALU_Out, Zero);

        // Division by zero
        A = 32'h3F800000; // 1.0 in IEEE 754
        B = 32'h00000000; // Zero
        ALU_Sel = 4'b1111;
        #10;
        $display("FP Div Special: 1.0 / 0 = %h (Zero=%b)", ALU_Out, Zero);

        // Additional Tests
        A = 32'h40400000; // 3.0
        B = 32'h00000000; // 0.0
        ALU_Sel = 4'b1111;
        #10;
        $display("FP Div: %f / 0 = %h (Zero=%b)", $bitstoshortreal(A), ALU_Out, Zero);

        A = 32'h00000000; // 0.0
        B = 32'h40400000; // 3.0
        ALU_Sel = 4'b1111;
        #10;
        $display("FP Div: 0 / %f = %f (Zero=%b)", $bitstoshortreal(B), $bitstoshortreal(ALU_Out), Zero);

        A = 32'h7F800000; // Infinity
        B = 32'h7F800000; // Infinity
        ALU_Sel = 4'b1111;
        #10;
        $display("FP Div: Inf / Inf = %h (Zero=%b)", ALU_Out, Zero);

        A = 32'h7F800000; // Infinity
        B = 32'h00000000; // 0.0
        ALU_Sel = 4'b1111;
        #10;
        $display("FP Div: Inf / 0 = %h (Zero=%b)", ALU_Out, Zero);

        A = 32'h00000000; // 0.0
        B = 32'h7F800000; // Infinity
        ALU_Sel = 4'b1111;
        #10;
        $display("FP Div: 0 / Inf = %f (Zero=%b)", $bitstoshortreal(ALU_Out), Zero);

        A = 32'h00000000; // 0.0
        B = 32'h00000000; // 0.0
        ALU_Sel = 4'b1111;
        #10;
        $display("FP Div: 0 / 0 = %h (Zero=%b)", ALU_Out, Zero);

        $stop;
    end

endmodule