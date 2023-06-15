riscv_mp2test.s:
.align 5
.section .text
.globl _start
    # Refer to the RISC-V ISA Spec for the functionality of
    # the instructions in this test program.
_start:
    # Note that the comments in this file should not be taken as
    # an example of good commenting style!!  They are merely provided
    # in an effort to help you understand the assembly style.

    # Note that one/two/eight are data labels
    la x10, result      # X10 <= Addr[result]
    sw x0, 0(x10)       # [Result]

    lw  x1, bad # X1 <- 0x40
    lw  x2, good
    add x3, x2, x1
    la x10, result      # X10 <= Addr[result]
    sw x3, 0(x10)       # [Result]

halt:                 # Infinite loop to keep the processor
    beq x0, x0, halt  # from trying to execute the data below.

.section .rodata

bad:        .word 0xdeadbeef
threshold:  .word 0x00000040
result:     .word 0x11077011
good:       .word 0x600d600d
test:       .word 0x00000000
