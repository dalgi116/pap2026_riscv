start:
_start:
    // 1. Load the first number into a0
    lw a0, num1

    // 2. Load the second number into a1
    lw a1, num2

    // 3. Jump to the GCD function (stores return address in ra)
    jal ra, gcd

    // 4. Store the result (returned in a0) back into memory
    sw a0, 1024(zero)

	ebreak

// ---------------------------------------------------------
// GCD Function
// Arguments: a0 = num1, a1 = num2
// Returns:   a0 = greatest common divisor
// ---------------------------------------------------------
gcd:
gcd_loop:
    // Base cases for Euclidean algorithm
    beq a0, zero, return_a1 // If a == 0, GCD is b (a1)
    beq a1, zero, return_a0 // If b == 0, GCD is a (a0)
    beq a0, a1, return_a0   // If a == b, GCD is a (a0)

    // If a < b, jump to b_is_greater
    blt a0, a1, b_is_greater   

a_is_greater:
    // a > b: subtract b from a
    sub a0, a0, a1             
    jal zero, gcd_loop  // Repeat loop

b_is_greater:
    // b > a: subtract a from b
    sub a1, a1, a0             
    jal zero, gcd_loop  // Repeat loop

return_a1:
    // Move a1 into a0 so the return value is always in a0
    add a0, zero, a1           

return_a0:
    // Return to the caller address stored in ra (x1)
    jalr zero, 0(ra)

data:
num1:   .word 56    // First number
num2:   .word 98    // Second number
result: .word 0     // Space to store the resulting GCD

.end start