/* Configure I/O devices (set mask, load period, etc.)(set the diretcion register or for the timer reading the period in and perhaps starting it)
1. Read a sensor
2. Read another sensor
3. Do some comparison (sensor vs. sensor, sensor vs. threshold, etc.)

r8: ADDR_JP1
r5: sensor 0
r6: sensor 1

*/
.data
.equ TIMER, 0xFF202000
.equ LED, 0xFF200000
.equ ADDR_JP1, 0xFF200060
# .equ ADDR_JP2, 0xFF200070
.equ sensor0onmask, 0xFFFFFBFF #motor is disabled
.equ sensor1onmask, 0xFFFFEFFF #motor is disabled
.equ motor0onFOR, 0xFFFFFFFC
.equ motor0onREV,0XFFFFFFFE
.equ motoroff, 0xFFFFFFFF

.global _start
.text
_start:

#set up direction register in JP1
#turn on motor0, forwards

	movia r8, ADDR_JP1

	movia r9, 0x07f557ff #set direction for motors to all output
	stwio r9, 4(r8)

	# movia r9, motor0onFOR #direction is forward
	# stwio r9, 0(r8)


#read value from sensor 0
read_sensor0_loop:

	movia r11, sensor0onmask
	sub   r11, r11, r15
	stwio r11, 0(r8)
	ldwio r10, 0(r8)
	srli r12, r10, 11 #bit 11 is the valid bit for sensor 0
	andi r12, r12, 0x1
	bne r0, r12, read_sensor0_loop
	# call read_sensor0

	ldwio  r5, 0(r8)
	srli r5, r5, 27 # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits
	andi r5, r5, 0x000F


#read value from sensor 1
read_sensor1_loop:

	movia r11, sensor1onmask
	sub   r11, r11, r15
	stwio r11, 0(r8)
	ldwio r10, 0(r8)
	srli r12, r10, 13 #bit 13 is the valid bit for sensor 1
	andi r12, r12, 0x1
	bne r0, r12, read_sensor1_loop
	# call read_sensor1_loop

	ldwio  r6, 0(r8)
	srli r6, r6, 27 # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits
	andi r6, r6, 0x000F

#compare two sensors
compare_sensor:
	#if sensor_val_0 = sensor_val_1, turn off the motor
	beq r5, r6, turn_off_motor
	#if sensor_val_0 < sensor_val_1, turn the lego to the other side
	blt r6, r5, rotate_to_sensor1
	#if sensor_val_0 > sensor_val_1, turn the lego to the other side
	bgt r6, r5, rotate_to_sensor0

rotate_to_sensor1:
	movia r10, motor0onFOR
	stwio r10, 0(r8)

	call delay_on

	movia r13, 0xFFFFFFFF
    sub  r15, r13, r10

	call just_turn_off_motor
	call delay_off

	br read_sensor0_loop

rotate_to_sensor0:
	movia r10, motor0onREV
	stwio r10, 0(r8)

	call delay_on

	movia r13, 0xFFFFFFFF
    sub  r15, r13, r10

	call just_turn_off_motor
	call delay_off

	br read_sensor0_loop

delay_on:
	movia r16, TIMER

	addi r17, r0, %lo(600000000)
	stwio r17, 8(r16)
	addi r17, r0, %hi(600000000)
	stwio r17, 12(r16)

	#tell timer to start

	stwio r0, 0(r16)
	movui r17, 6
	stwio r17, 4(r16)

	POLL_ON:

		ldwio r17, 0(r16)
		andi r17, r17, 1
		beq r17, r0, POLL_ON

		ret

delay_off:
	movia r18, TIMER

	addi r19, r0, %lo(400000000)
	stwio r19, 8(r18)
	addi r19, r0, %hi(400000000)
	stwio r19, 12(r18)

	#tell timer to start

	stwio r0, 0(r18)
	movui r19, 6
	stwio r19, 4(r18)

	POLL_OFF:

		ldwio r19, 0(r18)
		andi r19, r19, 1
		beq r19, r0, POLL_OFF

		ret

just_turn_off_motor:
	movia r10, motoroff
	stwio r10, 0(r8)
    sub  r15, r13, r10
	ret

turn_off_motor:
	movia r10, motoroff
	stwio r10, 0(r8)
    sub  r15, r13, r10
	br read_sensor0_loop
