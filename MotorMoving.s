
.equ GPIO_JP1, 0xFF200060   # Address GPIO JP1
.equ Timer1, 0xFF202000  # address of timer 1
.equ cycles, 12000000  # number of cycles in 1 second
.equ cycles2, 30000000  # number of cycles in 1 second
.equ STACK_ADDRESS, 0x04000000
.equ ADDR_JP1_IRQ, 0x880 
.equ STORE_DIRECTION, 0x02000000 
.equ PS2_CONTROLLER_1, 0xFF200100
.equ AUDIO, 0xFF203040

# Global variables:
# r10: current motor moving direction; forward is 0, reverse is 1, stop is 20000000
# r11: mode: 0 is auto, 1 is keyboard




.equ ADDR_JP2_DATA, 0xFF200070
.equ ADDR_LED, 0xFF200000    

.global _start
_start:
	movia sp,STACK_ADDRESS
	movia r10, 0x0 # initialize adjustion direction to forward
	movia r11, 0x1 # initialize to keyboard mode
	
	
	movia r16, Timer1
	movia r17, cycles
	movia  r8, GPIO_JP1

	movia  r9, 0x07f557ff    # set direction for motors to all output    
	stwio  r9, 4(r8)

	
	movia  r9, 0xffbffbff     # Enable sensor 0 for loading threshold
	stwio r9,0(r8)


	movia r9,0xffffffff  # Disable the load
	stwio r9,0(r8)
	
	
	movia  r9,  0xffbfefff     # Enable sensor 1 for loading threshold
	stwio r9,0(r8)
	
	movia r9,0xffdfffff  #  Disable the load and enable state mode #d:1101
	stwio r9,0(r8)
	
	call _sense

# enable interrupts
	movia r7,PS2_CONTROLLER_1
	
	# enable interrupt in keyboard
	stwio r0,4(r7)
	movia r13,0b1
	stwio r13,4(r7)


    movia  r12, 0x18000000       # enable interrupts on sensor 0 and 1
    stwio  r12, 8(r8)
	

    movia  r8, ADDR_JP1_IRQ    # enable interrupt for GPIO JP1 (IRQ11) 
    wrctl  ctl3, r8

    movia  r8, 1
    wrctl  ctl0, r8            # enable global interrupts 

 
LOOP:
	# check mode
	bne r11, r0, KEYBOARD_LOOP

    # write to GPIO_JP2
    movia r9, 0xFFFFFFFF
	stwio r9, 4(r5)
	 
	# initialize with 0
	movia r9, 0x0
	stwio r9, (r5)


    # read from GPIO_JP2
	movia r5, ADDR_JP2_DATA
	movia r9, 0x0
	stwio r9, 4(r5)
	 
	# load value inside
	ldwio r2, (r5)
	
	# mask
	andi r2, r2, 0b1
	beq r0, r2, STOP_MOTOR
	
	

MOVE:	
    beq r10, r0, MOVE_FORWARD
	bne r10, r0, MOVE_REVERSE

	
	
MOVE_FORWARD: 
# motor 0 & 1
	movia r8,GPIO_JP1
	movia	 r13,0xffdffff0 # 0000
	stwio	 r13, 0(r8) 

	call TIMER
	
	movia	 r13,0xffdfffff
	stwio	 r13, 0(r8)
	
	call TIMER2
	
	br LOOP
	
MOVE_REVERSE:
# motor 0 & 1
	movia r8,GPIO_JP1   
	movia	 r13,0xffdffffa  # 1010
	stwio	 r13, 0(r8)
	 
	call TIMER
	
	movia	 r13,0xffdfffff
	stwio	 r13, 0(r8)
	
	call TIMER2
	
	br LOOP

MOVE_LEFT:
# motor 0 & 1
	movia r8,GPIO_JP1   
	movia	 r13,0xffdffff4  # 0100
	stwio	 r13, 0(r8)
	 
	call TIMER
	
	movia	 r13,0xffdfffff
	stwio	 r13, 0(r8)
	
	call TIMER2
	
	br LOOP

MOVE_RIGHT:
# motor 0 & 1
	movia r8,GPIO_JP1   
	movia	 r13,0xffdffff1  # 0001
	stwio	 r13, 0(r8)
	 
	call TIMER
	
	movia	 r13,0xffdfffff
	stwio	 r13, 0(r8)
	
	call TIMER2
	
	br LOOP


	
STOP_MOTOR:
    movia r8, GPIO_JP1
	movia r16, 0xffdfffff # mode: state     motor0: OFF
	stw r16, 0(r8)
	
	
	br LOOP
	
		

TIMER:
    subi sp,sp,16
	stw r7,12(sp)
	stw r9,8(sp)
	stw r2,4(sp)
	stw r3,0(sp)

	movia r7, Timer1
    movui r9, %lo(cycles)
	stwio r9,8(r7)
	movui r9, %hi(cycles)
	stwio r9,12(r7)

	stwio r0,0(r7)

	movui r2,4
	stwio r2,4(r7)

POLL:	
	ldwio r2,0(r7)
	andi r3,r2,0b1
	beq r3,r0,POLL

	ldw r7,12(sp)
	ldw r9,8(sp)
	ldw r2,4(sp)
	ldw r3,0(sp)
	addi sp,sp,16
	ret 
	
	

TIMER2:
    subi sp,sp,16
	stw r7,12(sp)
	stw r9,8(sp)
	stw r2,4(sp)
	stw r3,0(sp)

	movia r7, Timer1
    movui r9, %lo(cycles2)
	stwio r9,8(r7)
	movui r9, %hi(cycles2)
	stwio r9,12(r7)

	stwio r0,0(r7)

	movui r2,4
	stwio r2,4(r7)

POLL2:	
	ldwio r2,0(r7)
	andi r3,r2,0b1
	beq r3,r0,POLL2

	ldw r7,12(sp)
	ldw r9,8(sp)
	ldw r2,4(sp)
	ldw r3,0(sp)
	addi sp,sp,16
	ret 
	
	
KEYBOARD_LOOP:
	beq r11,r0,LOOP
	br KEYBOARD_LOOP 
