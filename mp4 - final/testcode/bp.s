#  mp4-cp1.s version 4.0
.align 4
.section .text
.globl _start
_start:
pcrel_NEGTWO: auipc x10, %pcrel_hi(NEGTWO)
pcrel_TWO: auipc x11, %pcrel_hi(TWO)
pcrel_ONE: auipc x12, %pcrel_hi(ONE)
    addi x8, x8, 9
LOOP:
    addi x1, x1, 1
    xori x2, x2, 3
    beq x0, x0, LD_ST_TEST          #always taken
    nop
    nop
    nop
    nop
    nop
    nop
    nop

.section .rodata
.balign 256
ONE:    .word 0x00000001
TWO:    .word 0x00000002
NEGTWO: .word 0xFFFFFFFE
TEMP1:  .word 0x00000001
GOOD:   .word 0x600D600D
BADD:   .word 0xBADDBADD
BYTES:  .word 0x04030201
HALF:   .word 0x0020FFFF

.section .text
.align 4
LD_ST_TEST:
    addi x4, x4, 1
    add  x5, x4, x5
    bne x0, x0, HALT
    bne  x1, x8, LOOP                       #taken 9 times, then not taken
    pcrel_BYTES: auipc x9, %pcrel_hi(BYTES)
    nop
    pcrel_HALF: auipc x10, %pcrel_hi(HALF)
    nop
    nop
    beqz  x0, DONEa                         #taken
    nop
    nop
    nop
    nop

BADBAD:
pcrel_BADD: auipc x15, %pcrel_hi(BADD)
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    lw x1, %pcrel_lo(pcrel_BADD)(x15)
HALT:
    beq x0, x0, HALT
    nop
    nop
    nop
    nop
    nop
    nop
    nop

DONEa:
pcrel_GOOD: auipc x16, %pcrel_hi(GOOD)
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    lw x1, %pcrel_lo(pcrel_GOOD)(x16)
DONEb:
    beq x0, x0, DONEb
    nop
    nop
    nop
    nop
    nop
    nop
    nop
