.data
# TIMER1max controlls the PMW of the motor
.equ TIMER1max, 0xFF202000
# TIMER2max controlls Huberts dance moves
.equ TIMER2max, 0xFF202020
.equ LEDmax, 0xFF200000
.equ ADDR_JP1max, 0xFF200060
.equ ADDR_JP2max, 0xFF200070
.equ ADDR_AUDIODACFIFOmax, 0xFF203040
.equ LEDmax, 0xFF200000

.equ sensor0onmask, 0xFFFFFBFF #motor is disabLEDmax
.equ sensor1onmask, 0xFFFFEFFF #motor is disabLEDmax
.equ motor0onFOR, 0xFFFFFFFC
.equ motor0onREV,0XFFFFFFFE
.equ motoroff, 0xFFFFFFFF


.global _start
.text

_start:
    movia r2, ADDR_AUDIODACFIFOmax
    movia r4, LEDmax
	movia r5, ADDR_JP1max
	movia r6, TIMER1max
	movia r7, TIMER2max

	#initialize TIMER1max counter to count every second
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

	#initialize TIMER2max counter to count 2 seconds (120 bpm songs)
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
	mov r9, r0

    ldwio r3,4(r2)      # Read fifospace register
	andi  r3,r3,0xff    # Extract # of samples in Input Right Channel FIFO
	beq   r3,r0,loop    # If no samples in FIFO, go back to start

    # Echo to left channel
	ldwio r21,8(r2)
	stwio r21,8(r2)

    #writes to LEDmaxs
	srli r22, r21, 24
	stwio r22, 0(r4)

    #Instead of extracting the highest bit, I should see if its greater than a certain thresholds
	#r21 stores the FIFO in, compare that to threshold

	movhi r12, %hi(268435455) #0x2fffffff
	ori r12, r12, %low(268435455) #0x2fffffff
	
	#fakes audio data here
	#movi r21, 0xFFFFFFFF

	bgtu r21, r12, LOUD
	bltu r21, r12, QUIET

    LOUD:
	movi r15, 0b1
	br SHIFT_NEW_BIT

	QUIET:
	mov r15, r0
	br SHIFT_NEW_BIT

    #Shift newest bit into r20
	SHIFT_NEW_BIT:
	slli r20, r20, 0b1
	add r20, r20, r15

	#movi r3, 0xf
	
	#movhi r3, %hi(65535)
	#ori r3, r3, %lo(65535)	
	
	movi r3, 0x8
	
	andi r23, r20, 0xffff

	andi r8, r23, 0b0000000000000001
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b0000000000000010
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b0000000000000100
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b0000000000001000
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b0000000000010000
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b0000000000100000
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b0000000001000000
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b0000000010000000
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b0000000100000000
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b0000001000000000
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b0000010000000000
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b0000100000000000
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b0001000000000000
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b0010000000000000
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b0100000000000000
	bne r8, r0, ADD_ONE

	andi r8, r23, 0b1000000000000000
	bne r8, r0, ADD_ONE

	bgt r9, r3, MUSIC_YES
	#change this later
	br MUSIC_NO

	MUSIC_YES:
	movi r16, 0b1
	#movi r3, 0b1000000000
	#or r21, r21, r3
	#movi r21, 0b1110000000
	#stwio r21, 0(r4)
	br CONT2

	MUSIC_NO:
	mov r16, r0
	#movi r3, 0b0111111111
	#and r21, r21, r3
	#movi r21, 0b0000000111
	#stwio r21, 0(r4)
	br CONT2

    # Echo to right channel
    CONT2:
	ldwio r3,12(r2)
	stwio r3,12(r2)

br loop

.section .exceptions, "ax"
ISR:
	movia r5, ADDR_JP1max
	movia r6, TIMER1max
	movia r7, TIMER2max

	#Timer interrupt, used for PMW for leg speed
	subi sp, sp, 20
	stw r10, 0(sp)
	stw r11, 4(sp)
	stw r12, 8(sp)
	stw r13, 12(sp)
    stw r16, 16(sp)

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

    ldw et, 16(sp)
    beq et, r0, do_nothing

	ldw et, 4(sp)
	beq et, r0, turn_off
	bne et, r0, turn_on

do_nothing:
    #turns motors off
    movi r12, 0b11111111111111111111111111111111
    #stwio r12, 0(r5)
    #resets timer for time staying off
    stwio r0, 0(r6)
    #movui et, %lo(500000)
    #stwio et, 8(r6)
    #movui et, %hi(500000)
    #stwio et, 12(r6)
    #movi et, 5 #0b0101
    movi et, 1 #0b0001
    stwio et, 4(r6)
    br exit

turn_on:
	#turns motors according to what dance move Hubert should be doing
	movi r13, 0

	#store current snapshot of TIMER2max into r11
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
    movi r12, 0b11111111111111111111111111110010
	stwio r12, 0(r5)
	br turn_on_part2

shuffle_left:
	movi r12, 0b11111111111111111111111111111000
	stwio r12, 0(r5)
	br turn_on_part2

turn_on_part2:
	#movi r12, 0b11111111111111111111111111110010
	#stwio r12, 0(r5)
	#resets timer for time staying on
	stwio r0, 0(r6)
	movui et, %lo(1000000)
    stwio et, 8(r6)
    movui et, %hi(1000000)
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
	movui et, %lo(3000000)
    stwio et, 8(r6)
    movui et, %hi(3000000)
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
    ldw r16, 16(sp)
	addi sp, sp, 20
	addi ea, ea, -4
    eret

	
ADD_ONE:
	addi r9, r9, 1
	ret
