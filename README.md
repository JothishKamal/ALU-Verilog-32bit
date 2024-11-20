# 32-bit ALU Module Documentation

## Table of Contents
1. [Overview](#overview)
2. [ALU_32bit Module](#alu_32bit-module)
   - [Interface](#interface)
   - [Supported Operations](#supported-operations)
   - [Internal Components](#internal-components)
3. [Floating-Point Unit (FPU)](#floating-point-unit)
   - [fp_mul Module](#fp_mul-module)
   - [fp_div Module](#fp_div-module)
3. [ALU_32bit_tb Testbench](#alu_32bit_tb-testbench)
   - [Test Cases](#test-cases)
   - [Sample Output](#sample-output)
5. [Notes](#notes)

---

## Overview
This document provides an overview of the `ALU_32bit` module and its testbench `ALU_32bit_tb` implemented in Verilog. The module is a 32-bit Arithmetic Logic Unit (ALU) that performs various arithmetic and logical operations, including signed and unsigned integer operations, comparisons, and floating-point arithmetic.

---

## ALU_32bit Module

### Interface

**Inputs:**
- `input [31:0] A`  
  First 32-bit operand.
- `input [31:0] B`  
  Second 32-bit operand.
- `input [3:0] ALU_Sel`  
  4-bit selection input to choose the ALU operation.

**Outputs:**
- `output reg [31:0] ALU_Out`  
  32-bit result of the ALU operation.
- `output Zero`  
  Zero flag; high (`1`) when `ALU_Out` is zero.

---

### Supported Operations
The ALU performs operations based on the `ALU_Sel` input:

#### Unsigned Integer Operations:
- `0000`: Addition (`A + B`)
- `0001`: Subtraction (`A - B`)
- `0010`: Multiplication (`A * B`)
- `0011`: Division (`A / B`), with zero check

#### Signed Integer Operations:
- `0100`: Addition (`signed_A + signed_B`)
- `0101`: Subtraction (`signed_A - signed_B`)
- `0110`: Multiplication (`signed_A * signed_B`)
- `0111`: Division (`signed_A / signed_B`), with zero check

#### Comparison Operations:
- `1000`: Less Than (`signed_A < signed_B`)
- `1001`: Less Than or Equal (`signed_A <= signed_B`)
- `1010`: Greater Than (`signed_A > signed_B`)
- `1011`: Greater Than or Equal (`signed_A >= signed_B`)
- `1100`: Equal (`A == B`)
- `1101`: Not Equal (`A != B`)

#### Floating-Point Operations:
- `1110`: Multiplication (`fp_mul`)
- `1111`: Division (`fp_div`)

---

### Internal Components
1. **Signed Interpretation:**  
   Enables signed arithmetic operations.
2. **Floating-Point Units:**  
   Performs floating-point arithmetic using `fp_mul` and `fp_div`.
3. **Multiplier:**  
   Handles both integer and floating-point multiplications.
4. **Divider:**  
   Handles both integer and floating-point divisions.
5. **Zero Flag:**  
   The `Zero` output is asserted when `ALU_Out` is zero.

---

## Floating-Point Unit

### fp_mul Module
The `fp_mul` module performs floating-point multiplication in IEEE 754 format.

#### Interface
**Inputs:**
- `input [31:0] A`: Input floating-point number A  
- `input [31:0] B`: Input floating-point number B  

**Outputs:**
- `output [31:0] Result`: Result of floating-point multiplication  

#### Special Case Handling:
- Multiplication by zero or infinity returns results based on IEEE 754 standards.
- NaN and infinity inputs are processed appropriately.

---

### fp_div Module
The `fp_div` module performs floating-point division in IEEE 754 format.

#### Interface
**Inputs:**
- `input [31:0] A`: Dividend (Floating-point number)  
- `input [31:0] B`: Divisor (Floating-point number)  

**Outputs:**
- `output [31:0] Result`: Result of floating-point division  

#### Special Case Handling:
- Division by zero returns infinity or NaN, based on IEEE 754 standards.
- Zero divided by a finite number returns zero.  

---

## ALU_32bit_tb Testbench
The `ALU_32bit_tb` module tests the functionality of the ALU with various test cases.

### Test Cases
1. **Unsigned Integer Operations:**  
   Addition, Subtraction, Multiplication, Division
2. **Signed Integer Operations:**  
   Addition, Subtraction, Multiplication, Division
3. **Comparison Operations:**  
   Less Than, Less Than or Equal, Greater Than, Greater Than or Equal, Equal, Not Equal
4. **Floating-Point Operations:**  
   Multiplication, Division
5. **Special Cases:**  
   Operations involving infinity, zero, and division by zero

### Sample Output

```verilog
# Unsigned Add:         10 +         20 =         30 (Zero=0)
# Unsigned Sub:         50 -         20 =         30 (Zero=0)
# Unsigned Mul:          7 *          3 =         21 (Zero=0)
# Unsigned Div:        100 /          4 =         25 (Zero=0)
# Signed Add:         -25 +          10 =         -15 (Zero=0)
# Signed Sub:         -25 -          10 =         -35 (Zero=0)
# Signed Mul:          -5 *           6 =         -30 (Zero=0)
# Signed Div:         -20 /          -4 =           5 (Zero=0)
# Less Than:          10 <          20 =          1 (Zero=0)
# Less Equal:          10 <=          20 =          1 (Zero=0)
# Greater Than:          30 >          20 =          1 (Zero=0)
# Greater Equal:          30 >=          20 =          1 (Zero=0)
# Equal:          20 ==          20 =          1 (Zero=0)
# Not Equal:          20 !=          15 =          1 (Zero=0)
# FP Mul: 2.500000 * 4.000000 = 10.000000 (Zero=0)
# FP Div: 15.000000 / 3.000000 = 5.000000 (Zero=0)
# FP Mul Special: Inf * 0 = 7fc00000 (Zero=0)
# FP Div Special: 1.0 / 0 = 7f800000 (Zero=0)
# FP Div: 3.000000 / 0 = 7f800000 (Zero=0)
# FP Div: 0 / 3.000000 = 0.000000 (Zero=1)
# FP Div: Inf / Inf = 7fc00000 (Zero=0)
# FP Div: Inf / 0 = 7fc00000 (Zero=0)
# FP Div: 0 / Inf = 1.#QNAN0 (Zero=0)
# FP Div: 0 / 0 = 7fc00000 (Zero=0)
```

---

## Notes
1. **Floating-Point Numbers:**  
   Operands for floating-point operations should be in IEEE 754 format.
2. **Special Cases Handling:**  
   The ALU handles division by zero and operations with infinity, returning zero or appropriate representations as per IEEE standards.
3. **Dependencies:**  
   Ensure that `fp_mul.v` and `fp_div.v` modules are included for floating-point operations.
