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
    lw  x1, bad # X1 <- 0x40
    lw  x2, good
    add x3, x2, x1
    la x1, stringg       # X2 <= stringg
    lw  x3, bad

loop1:
    lw x2, 0(x1)
    sw x0, 0(x1)
    addi x1, x1, 4   
    bne x2, x3, loop1   # Branch if last result was zero or positive.

halt:                 # Infinite loop to keep the processor
    beq x0, x0, halt  # from trying to execute the data below.

.section .rodata


threshold:  .word 0x00000040
result:     .word 0x78787878
good:       .word 0x600d600d
test:       .word 0x11000011
            .word 0x11000011
            .word 0x11000011
            .word 0x11000011
stringg:    .string "This is a sasdsssasdfsreally long string of data that we could use to test out the CPU and stress our cache with lots of different addresses to see if conflict misses are handled correctly by the LRU and stuff alskjdbaslfjihbqewli hba;ilsfhba;i hfbaljsfhbdalsdijb adbw ihbfgws; fbnwei; baewri;j gnaerigheiaruieragblauerhby gkuawevfkawhg fa,wjehbvf akwbgealurkhgbakejr hv gkjawehvfkajwegdvf,jwaeh fkhagwevflauw eyg fkuawhebfkjawb cfkuawcegku awe vlfauwbe rftkuaw  beflcahw lrfawb elitc hjwabelifbga ewl.c fgb2awejc hfga wel iuguh awelitalwegkquewrhytgvicaetkuawevgfualwhbgljhb"
bad:        .word 0xdeadbeef