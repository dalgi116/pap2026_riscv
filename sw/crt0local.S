/* minimal replacement of crt0.o which is else provided by C library */

.globl main
.globl _start
.globl __start

.option norelax

.text

.section .text._start

__start:
_start:
	.option push
	.option norelax
	la gp, __global_pointer$
	.option pop
	la      sp, __stack_end
	addi    a0, zero, 0
	addi    a1, zero, 0
	jal     main
quit:
	addi    a0, zero, 0
	addi    a7, zero, 93  /* SYS_exit */
	ecall

loop:	ebreak
        beq     zero, zero, loop

.bss

__stack_start:
	.skip   4096
__stack_end:

.end _start
