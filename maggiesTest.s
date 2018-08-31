.equ TIMER, 0xFF202000
.equ LEGO, 0xFF200060
.equ LEGO_EDGE_CAPTURE, 0xFF20006C
.equ IRQ_11, 0x800
.equ IRQ_7, 0x80
.equ IRQ_8, 0X100
.equ JTAG_UART, 0xFF201000
.equ PS2KEYBOARD, 0xFF201000
.equ LEDR, 0xFF200000


# motor 1 is the motor on the left and motor 0 is the sesor on the right
.equ motor_forward, 0xFFFFFFF0 # 0000
.equ motor_backward, 0xFFFFFFFA # 1010
.equ motor_right, 0xFFFFFFF1 # turn off the right motor 0001
.equ motor_left, 0xFFFFFFF4 # turn off the left motor 0100
.equ motor_stop, 0xFFFFFFFF # 0101
#  forward=0, reverse=1; on=0, off=1

.data
thechar:	.byte ' '


.section .text
.global _start
_start:

	#movia r27, 0x800000
	movia r8, TIMER # set the timer to 10 seconds 
	movia r9, 0x6500  # 1DCD6500
	stwio r9, 8(r8)
	movia r9, 0x1DCD
	stwio r9, 12(r8)
	movia r9, 0x0 # clear the timer
	stwio r9, 0(r8)
	ldwio r9, 0(r8)

	movia r11, LEGO
	movia r9, 0x07F557FF # Direction Register
	stwio r9, 4(r11)
	movia r9, 0xFFFFFFFF
	stwio r9,0(r11)

	movia r9, 0xFFBFFBFF # sensor 0
	stwio r9, 0(r11)

	movia r9, 0xFFBFEFFF   # sensor 1    
    stwio r9,0(r11)

    movia r9, 0xFFBFFFFF # disable sensor 
    stwio r9,0(r11)

    movia r9, 0xFFDFFFFF # disable the load and set it to the state mode
    stwio r9,0(r11)


    movia r8, PS2KEYBOARD

    addi r9, r0, 0x1 
    stwio r9, 4(r8)

    addi r9, r0, 0x900 # ctl3 irq 8 and 11 is 1
    wrctl ctl3, r9

    movia r9, 1
    wrctl ctl3, r9

    movia r9, LEGO_EDGE_CAPTURE # clear lego sensor edge 
    addi r9, r0, 0x1


run_loop:
	movia r9, LEDR
    
    movia r20,LEGO

    ldwio r19,0(r20)
    srli r19,r19,26
    stwio r19, 0(r9)
    
    
    movia r9,LEGO_EDGE_CAPTURE
    addi r9, r0, 0x1
    br run_loop

















motors_forward:
    addi sp,sp,-4
    stw r16,0(sp)

    movia r16,motors_forward
    stwio r16,0(r4)

    ldw r16,0(sp)
    addi sp,sp,4
    ret




motors_backward:
    addi sp,sp,-4
    stw r16,0(sp)

    movia r16,motors_backward
    stwio r16,0(r4)

    ldw r16,0(sp)
    addi sp,sp,4
    ret




motors_turn_right:
    addi sp,sp,-4
    stw r16,0(sp)

    movia r16,motors_turn_right           
    stwio r16,0(r4)

    ldw r16,0(sp)
    addi sp,sp,4
    ret




motors_turn_left:
    addi sp,sp,-4
    stw r16,0(sp)

    movia r16,motors_turn_left           

    ldw r16,0(sp)
    addi sp,sp,4
    ret



motors_stop:
    addi sp,sp,-4
    stw r16,0(sp)

    movia r16,motors_stop
    stwio r16,0(r4)

    ldw r16,0(sp)
    addi sp,sp,4
    ret




wall_escape_right:
	movia r8, TIMER
	stw r0, 0(r8)

	movia r9, 0x4 # 0b0100
	stw r9,4(r8)

	movia r4, LEGO

	addi sp, sp, -16
	stw ra, 0(sp)
	stw r8, 4(sp)
	stw r9, 8(sp)
	stw r11, 12(sp)

	call motors_turn_right

	ldw ra, 0(sp)
	ldw r8, 4(sp)
	ldw r9, 8(sp)
	ldw r11, 12(sp)
	addi sp, sp, 16

right_loop:
	ldw r9, 0(r8)
	movia r10, 0x00000001
	and r9,r9,r10
	beq r9, r10, right_clear
	br right_loop
right_clear:
	stw r0,0(r8)
	addi sp, sp, -16
	stw ra, 0(sp)
	stw r8, 4(sp)
	stw r9, 8(sp)
	stw r11, 12(sp)

	movia r4, LEGO
	call motors_forward

	ldw ra, 0(sp)
	ldw r8, 4(sp)
	ldw r9, 8(sp)
	ldw r11, 12(sp)
	addi sp, sp, 16
	ret



wall_escape_left:
	movia r8, TIMER
	stw r0, 0(r8)

	movia r9, 0x4 # 0b0100
	stw r9,4(r8)

	movia r4, LEGO

	addi sp, sp, -16
	stw ra, 0(sp)
	stw r8, 4(sp)
	stw r9, 8(sp)
	stw r11, 12(sp)

	call motors_turn_left

	ldw ra, 0(sp)
	ldw r8, 4(sp)
	ldw r9, 8(sp)
	ldw r11, 12(sp)
	addi sp, sp, 16

left_loop:
	ldw r9, 0(r8)
	movia r10, 0x00000001
	and r9,r9,r10
	beq r9, r10, left_clear
	br left_loop
left_clear:
	stw r0,0(r8)
	addi sp, sp, -16
	stw ra, 0(sp)
	stw r8, 4(sp)
	stw r9, 8(sp)
	stw r11, 12(sp)

	movia r4, LEGO
	call motors_forward

	ldw ra, 0(sp)
	ldw r8, 4(sp)
	ldw r9, 8(sp)
	ldw r11, 12(sp)
	addi sp, sp, 16
	ret




	



	.section .exceptions, "ax"
	.align 2

	handler:
		addi sp, sp, -12
		stw et, 0(sp)
		rdctl et, ctl1
		stw et, 4(sp)
		stw ea, 8(sp)

		addi sp, sp, -32
		stw r8, 0(sp)
		stw r9, 4(sp)
		stw r10, 8(sp)
		stw r11, 12(sp)
		stw r12, 16(sp)
		stw r13, 20(sp)
		stw r14, 24(sp)
		stw r15, 28(sp)

		rdctl et, ctl4 # check the interrpt ipending register ctl4
		andi et, et, IRQ_11 # check if the interrpt is from GPIO JP1
		bne et, r0, handle_sensor

		rdctl et, ctl4
		andi, et, et, IRQ_7
		bne et, r0, handle_JTAG

		br exit_handler

	handle_sensor:

		movia r2, LEGO # load JP1 into r2
		ldwio r4, 0(r2)
		srli r4, r4, 27
		andi r4, r4, 0x01f # 0b0000 0001 1111 check if sensor values are all 1
		cmpeqi r5, r4, 0x01f # sign extend the 16 bit imm to 32 ad compares it to the value of r4, if r4 == imm16, then r5 is 1, otherwise stores 0

		bne r5, r0, exit_handler

		cmpeqi r5, r4, 0x01e # 0000 0001 1110 check sensor 0
		bne r5, r0, handle_sensor_left

		cmpeqi r5, r4, 0x01d # 0000 0001 1101 check sensor 1
		bne r5, r0, handle_sensor_right

		br exit_handler

	handle_JTAG:

		movia r7, PS2KEYBOARD
		ldwio r2, 0(r7)
		andi r13, r2, 0x8000 # 1000 0000 0000 0000 check if bit15(read data is valid)
		beq r13, r0, exit_handler
		andi r2, r2, 0xff # mask lower byte which is the data itself

		# check keyboard input 
		movia r12, 'f'
		beq r2, r12, handle_forward

		movia r12, 's'
		beq r2, r12, handle_stop

		movia r12, 'r'
		beq r2, r12, handle_reverse

		movia r12, 'l'
		beq r2, r12, handle_left

		movia r12, 'r'
		beq r2, r12, handle_right

		br exit_handler

	handle_sensor_left:
		addi sp, sp, -32
		stw r8, 0(sp)
		stw r9, 4(sp)
		stw r10, 8(sp)
		stw r11, 12(sp)
		stw r12, 16(sp)
		stw r13, 20(sp)
		stw r14, 24(sp)
		stw r15, 28(sp)

		movia r4, LEGO

		call wall_escape_right
		ldw r8,0(sp)
		ldw r9,4(sp)
		ldw r10,8(sp)
		ldw r11,12(sp)
		ldw r12,16(sp)
		ldw r13,20(sp)
		ldw r14,24(sp)
		ldw r15,30(sp)
		addi sp,sp,32

		movi et, 0x1 
		wrctl ctl0, et # set PIE (ctl0) back to 1 to reenable
		br exit_handler

	handle_sensor_right:
		addi sp, sp, -32
		stw r8, 0(sp)
		stw r9, 4(sp)
		stw r10, 8(sp)
		stw r11, 12(sp)
		stw r12, 16(sp)
		stw r13, 20(sp)
		stw r14, 24(sp)
		stw r15, 28(sp)

		movia r4, LEGO

		call wall_escape_left
		ldw r8,0(sp)
		ldw r9,4(sp)
		ldw r10,8(sp)
		ldw r11,12(sp)
		ldw r12,16(sp)
		ldw r13,20(sp)
		ldw r14,24(sp)
		ldw r15,30(sp)
		addi sp,sp,32

		movi et, 0x1 
		wrctl ctl0, et # set PIE (ctl0) back to 1 to reenable
		br exit_handler

	handle_forward:
		movia r7, JTAG_UART
		ldwio r7,0(r7)
		movi et, 0x1 
		wrctl ctl0, et # set PIE (ctl0) back to 1 to reenable

		addi sp, sp, -32
		stw r8, 0(sp)
		stw r9, 4(sp)
		stw r10, 8(sp)
		stw r11, 12(sp)
		stw r12, 16(sp)
		stw r13, 20(sp)
		stw r14, 24(sp)
		stw r15, 28(sp)

		movia r4, LEGO

		call motors_forward
		ldw r8,0(sp)
		ldw r9,4(sp)
		ldw r10,8(sp)
		ldw r11,12(sp)
		ldw r12,16(sp)
		ldw r13,20(sp)
		ldw r14,24(sp)
		ldw r15,30(sp)
		addi sp,sp,32
		br exit_handler

	handle_reverse:
		movia r7, JTAG_UART
		ldwio r7,0(r7)
		movi et, 0x1 
		wrctl ctl0, et # set PIE (ctl0) back to 1 to reenable

		addi sp, sp, -32
		stw r8, 0(sp)
		stw r9, 4(sp)
		stw r10, 8(sp)
		stw r11, 12(sp)
		stw r12, 16(sp)
		stw r13, 20(sp)
		stw r14, 24(sp)
		stw r15, 28(sp)

		movia r4, LEGO

		call motors_backward
		ldw r8,0(sp)
		ldw r9,4(sp)
		ldw r10,8(sp)
		ldw r11,12(sp)
		ldw r12,16(sp)
		ldw r13,20(sp)
		ldw r14,24(sp)
		ldw r15,30(sp)
		addi sp,sp,32
		br exit_handler

	handle_left:
		movia r7, JTAG_UART
		ldwio r7,0(r7)
		movi et, 0x1 
		wrctl ctl0, et # set PIE (ctl0) back to 1 to reenable

		addi sp, sp, -32
		stw r8, 0(sp)
		stw r9, 4(sp)
		stw r10, 8(sp)
		stw r11, 12(sp)
		stw r12, 16(sp)
		stw r13, 20(sp)
		stw r14, 24(sp)
		stw r15, 28(sp)

		movia r4, LEGO

		call motors_turn_left
		ldw r8,0(sp)
		ldw r9,4(sp)
		ldw r10,8(sp)
		ldw r11,12(sp)
		ldw r12,16(sp)
		ldw r13,20(sp)
		ldw r14,24(sp)
		ldw r15,30(sp)
		addi sp,sp,32
		br exit_handler


	handle_right:
		movia r7, JTAG_UART
		ldwio r7,0(r7)
		movi et, 0x1 
		wrctl ctl0, et # set PIE (ctl0) back to 1 to reenable

		addi sp, sp, -32
		stw r8, 0(sp)
		stw r9, 4(sp)
		stw r10, 8(sp)
		stw r11, 12(sp)
		stw r12, 16(sp)
		stw r13, 20(sp)
		stw r14, 24(sp)
		stw r15, 28(sp)

		movia r4, LEGO

		call motors_turn_right
		ldw r8,0(sp)
		ldw r9,4(sp)
		ldw r10,8(sp)
		ldw r11,12(sp)
		ldw r12,16(sp)
		ldw r13,20(sp)
		ldw r14,24(sp)
		ldw r15,30(sp)
		addi sp,sp,32
		br exit_handler


	handle_stop:
		movia r7, JTAG_UART
		ldwio r7,0(r7)
		movi et, 0x1 
		wrctl ctl0, et # set PIE (ctl0) back to 1 to reenable

		addi sp, sp, -32
		stw r8, 0(sp)
		stw r9, 4(sp)
		stw r10, 8(sp)
		stw r11, 12(sp)
		stw r12, 16(sp)
		stw r13, 20(sp)
		stw r14, 24(sp)
		stw r15, 28(sp)

		movia r4, LEGO

		call motors_stop
		ldw r8,0(sp)
		ldw r9,4(sp)
		ldw r10,8(sp)
		ldw r11,12(sp)
		ldw r12,16(sp)
		ldw r13,20(sp)
		ldw r14,24(sp)
		ldw r15,30(sp)
		addi sp,sp,32
		br exit_handler

	exit_handler:
		movia r9, LEGO_EDGE_CAPTURE
		stwio r0, 0(r9)

		ldw r8,0(sp)
		ldw r9,4(sp)
		ldw r10,8(sp)
		ldw r11,12(sp)
		ldw r12,16(sp)
		ldw r13,20(sp)
		ldw r14,24(sp)
		ldw r15,30(sp)
		addi sp,sp,32

		ldw et, 0(sp)
		ldw et, 4(sp)
		wrctl ctl1, et # restore ctl1
		ldw ea, 8(sp)
		addi sp, sp, 12
		subi ea, ea, 4 # on exit adjust return value such the last instruction executes

		eret # exception return










