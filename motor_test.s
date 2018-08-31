.data
# TIMER1 controlls the PMW of the motor
.equ TIMER1, 0xFF202000
# TIMER2 controlls Huberts dance moves
.equ TIMER2, 0xFF202020
.equ LED, 0xFF200000
.equ ADDR_JP1, 0xFF200060
# .equ ADDR_JP2, 0xFF200070
.equ sensor0onmask, 0xFFFFFBFF #motor is disabled
.equ sensor1onmask, 0xFFFFEFFF #motor is disabled
.equ motor0onFOR, 0xFFFFFFFC
.equ motor0onREV,0XFFFFFFFE
.equ motoroff, 0xFFFFFFFF

.global main2
.text

main2:
	movia r5, ADDR_JP1
	movia r6, TIMER1
	movia r7, TIMER2

	#initialize timer1 counter to count every second
    movui r10, %lo(1000000)
    stwio r10, 8(r6)
    movui r10, %hi(1000000)
    stwio r10, 12(r6)
	#setup and start timer (!stop, start, !cont, interrupt)
	movi r10, 0b0101
	stwio r10, 4(r6)
	#reset timer
    #stwio r0, 0(r6)
	#initialize "going" boolean (0 is going 1 is not going)
	movi r11, 0

	#initialize timer2 counter to count 2 seconds (120 bpm songs)
    movui r10, %lo(96774192)
    stwio r10, 8(r7)
    movui r10, %hi(96774192)
    stwio r10, 12(r7)
	#setup and start timer (!stop, start, cont, !interrupt)
	movi r10, 0b0110
	stwio r10, 4(r7)
	#reset timer
    #stwio r0, 0(r7)

	#magic number to set direction for motors to all output
	movia r10, 0x07f557ff
	stwio r10, 4(r5)

	#enable external interrupts (IRQ line and PIE)
    movi r10, 0b1
    wrctl ienable, r10 #IRQ line
    movi r10, 0b1
    wrctl status, r10 #PIE

	movi r10, 0xFFFFFFFF

loop: #Hubert goes forward loop
	stwio r10, 0(r5)
	br loop

.section .exceptions, "ax"
ISR:
	movia r5, ADDR_JP1
	movia r6, TIMER1
	movia r7, TIMER2

	#Timer interrupt only, used for PMW for leg speed
	subi sp, sp, 16
	stw r10, 0(sp)
	stw r11, 4(sp)
	stw r12, 8(sp)
	stw r13, 12(sp)
	rdctl et, ipending
    andi et, et, 0x1
    beq et, r0, exit

    # turns Hubert on/off
	# first checks if hes going or not
	# #if going, turn off, set timer accordingly
	# #if not going, turn on, set timer accordingly

	# mask all bits except the first 4 bits that controlls his legs, and check if theyre on or not
	# if it's 0, then it's currently on -> need to turn off
	# if it's 1, then it's currently off -> need to turn on

	# checks first motor
	# ldwio et, 0(r5)
	# andhi et, et, 0x0000
	# andi et, et, 0b0001
    # beq et, r0, turn_off

	# checks second motor
	# ldwio et, 0(r5)
	# andhi et, et, 0x0000
	# andi et, et, 0b0100
	# br et, r0, turn_off

	ldw et, 4(sp)
	beq et, r0, turn_off
	bne et, r0, turn_on

turn_on:
	#turns motors according to what dance move Hubert should be doing
	movi r13, 0

	#store current snapshot of TIMER2 into r11
	#then check r11 to see what move Hubert should be doing (what to send to r10)
	stwio r0, 16(r7)
	ldwio r10, 16(r7)
	ldwio r11, 20(r7)
	slli r11, r11, 16
	or r11, r11, r10
	movhi et, %hi(48387096)
    ori et, et, %lo(48387096)
	bgt r11, et, shuffle_right
	br shuffle_left

shuffle_right:
	#movi r12, 0b11111111111111111111111111111000
	movi r12, 0b11111111111111111111111000111111
	stwio r12, 0(r5)
	br turn_on_part2

shuffle_left:
	#movi r12, 0b11111111111111111111111111110010
	movi r12, 0b11111111111111111111110010111111
	stwio r12, 0(r5)
	br turn_on_part2

turn_on_part2:
	#movi r12, 0b11111111111111111111111111110010
	#stwio r12, 0(r5)
	#resets timer for time staying on
	stwio r0, 0(r6)
	movui et, %lo(500000)
    stwio et, 8(r6)
    movui et, %hi(500000)
    stwio et, 12(r6)
	movi et, 5 #0b0101
	stwio et, 4(r6)
	br exit

turn_off:
	#turns motors off
	movi r13, 1
	movi r12, 0b11111111111111111111111111111111
	#stwio r12, 0(r5)
	#resets timer for time staying off
	stwio r0, 0(r6)
	movui et, %lo(4000000)
    stwio et, 8(r6)
    movui et, %hi(4000000)
    stwio et, 12(r6)
	movi et, 5 #0b0101
	stwio et, 4(r6)
	br exit

exit:
	ldw r10, 0(sp)
	mov r10, r12
	ldw r11, 4(sp)
	mov r11, r13
	ldw r12, 8(sp)
	ldw r13, 12(sp)
	addi sp, sp, 16
	addi ea, ea, -4
    eret
