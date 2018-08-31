.equ ADDR_AUDIODACFIFO, 0xFF203040
.equ LED, 0xFF200000

.global _start

_start:
	movia r2, ADDR_AUDIODACFIFO
	movia r3, LED
	movi r10, 0b0000001101 #(!write pending, !read pending, clear FIFO in, clear FIFO out, !write interrupt, read interrupt)
	stwio r10, 0(r2)

	#enable external interrupts (IRQ line and PIE)
    movi r10, 0b1000000
    wrctl ienable, r10 #IRQ line
    movi r10, 0b1
    wrctl status, r10 #PIE

	br listening


listening:
	br listening

.section .exceptions, "ax"
ISR:
	rdctl et, ipending
    andi et, et, 0b1000000
    beq et, r0, exit

	movi et, 0xff
	stwio et, 0(r3)
	br exit

exit:
	addi ea, ea, -4
    eret
