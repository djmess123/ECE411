riscv_mp2test.s:
.align 4
.section .text
.globl _start
    # Refer to the RISC-V ISA Spec for the functionality of
    # the instructions in this test program.
_start:
    # Note that the comments in this file should not be taken as
    # an example of good commenting style!!  They are merely provided
    # in an effort to help you understand the assembly style.

    # Note that one/two/eight are data labels
    lw  x1, threshold # X1 <- 0x40

    #test load partials -------------

    lw  x15, _start + 4

    lh  x16, _start + 4
    lh  x17, _start + 6

    lhu x18, _start + 4
    lhu x19, _start + 6

    lb  x20, _start + 4
    lb  x21, _start + 5
    lb  x22, _start + 6
    lb  x23, _start + 7

    lbu x24, _start + 4
    lbu x25, _start + 5
    lbu x26, _start + 6
    lbu x27, _start + 7


    #test store partials ----------------

    lw  x27, bad

    la x10, test        # X10 <= Addr[test]

    #sw  x27, 0(x10)  

    #sh  x27, 4(x10)  
    #sh  x27, 8(x10)  

    #sb  x27, 12(x10)  
    #sb  x27, 16(x10)  
    #sb  x27, 20(x10)  
    #sb  x27, 24(x10)  

    #test JAL
    jal x13, testjal #1
    jal x14, regreg #3

    #sb  x27, 12(x10)  #filler, gets skipped always
    #sb  x27, 16(x10)  
    #sb  x27, 20(x10)  
    #sb  x27, 24(x10)  

testjal:
    jalr x12, 0(x13) #2
     

    #sb  x27, 12(x10)  #filler, gets skipped always
    #sb  x27, 16(x10)  
    #sb  x27, 20(x10)  
    #sb  x27, 24(x10)

regreg:
                     #4
    # test logical reg-reg
    and x1, x2, x3;
    or  x1, x2, x3;
    XOR x1, x2, x3;
    sll x1, x2, x3;
    srl x1, x2, x3;

    #test arithmetic reg-reg
    sra x1, x2, x3;
    add x1, x2, x3;
    sub x1, x2, x3;
    slt x1, x2, x3;
    sltu x1, x2, x3;


# begin normal test

    lui  x2, 2       # X2 <= 2
    lui  x3, 8     # X3 <= 8
    srli x2, x2, 12
    srli x3, x3, 12

    addi x4, x3, 4    # X4 <= X3 + 2

loop1:
    slli x3, x3, 1    # X3 <= X3 << 1
    xori x5, x2, 127  # X5 <= XOR (X2, 7b'1111111)
    addi x5, x5, 1    # X5 <= X5 + 1
    addi x4, x4, 4    # X4 <= X4 + 8

    bleu x4, x1, loop1   # Branch if last result was zero or positive.

    andi x6, x3, 64   # X6 <= X3 + 64

    auipc x7, 8         # X7 <= PC + 8
    lw x8, good         # X8 <= 0x600d600d
    la x10, result      # X10 <= Addr[result]
    #sw x8, 0(x10)       # [Result] <= 0x600d600d
    lw x9, result       # X9 <= [Result]
    bne x8, x9, deadend # PC <= bad if x8 != x9

halt:                 # Infinite loop to keep the processor
    beq x0, x0, halt  # from trying to execute the data below.
                      # Your own programs should also make use
                      # of an infinite loop at the end.

deadend:
    lw x8, bad     # X8 <= 0xdeadbeef
deadloop:
    beq x8, x8, deadloop

.section .rodata

bad:        .word 0xdeadbeef
threshold:  .word 0x00000040
result:     .word 0x00000000
good:       .word 0x600d600d
test:       .word 0x00000000

