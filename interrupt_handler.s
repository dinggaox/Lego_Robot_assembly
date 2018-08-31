.equ GPIO_JP1, 0xFF200060   # Address GPIO JP1
.equ ADDR_JP1_EDGE, 0xFF20006C      # address Edge Capture register GPIO JP1
.equ MOVING_LEFT, 0
.equ MOVING_RIGHT, 1
.equ STORE_DIRECTION, 0x02000000 #memory address that holds the current direction of the motor
.equ PS2_CONTROLLER_1, 0xFF200100
.equ ADDR_LED, 0xFF200000 
.equ A_CHAR, 0x1C
.equ BREAK, 0xF0
.equ D_CHAR, 0x23
.equ M_CHAR, 0x3A
.equ W_CHAR, 0x1D
.equ X_CHAR, 0x22
.equ K_CHAR, 0x42
.equ AUDIO, 0xFF203040
.equ MOTOR3, 0xFFDFFC0F
.equ MOTOR4, 0xFFDFFF3F
.equ MOTOR5, 0xFFDFFCFF


# JP2
.equ ADDR_JP2_EDGE, 0xFF20007C

.section .exceptions, "ax"
.global interrupt_handler


interrupt_handler:

	
	#store the previous state
	subi sp,sp,32
	stw r16,(sp)
	stw r17,4(sp)
	stw et,8(sp)
	stw r18,20(sp)
	stw r19,24(sp)
	stw r20,28(sp)
	rdctl et,estatus
	stw et,12(sp)
	stw ea,16(sp)
	
	#Check keyboard
	rdctl et,ctl4
	andi et,et,0x80
	bne et, r0, AKNOWLEGE_KEYBOARD
	
	
	
	#Check JP1
	rdctl et,ctl4
	andi et,et,0x800
	beq et,r0, ACKNOWLEDGE_JP1
	bne et, r0, SERVE_TOUCHSENSOR

AKNOWLEGE_KEYBOARD:
	
	
LOOP1:
	movia et, PS2_CONTROLLER_1
	ldwio r16, 0(et)
	
	#check if there are still chars to read
	movia et,0x8000
	and et,r16,et
	beq et,r0,EXIT
	

	
	#mask the last 8 bits of data
	andi et,r16,0xFF
	
	movia r17,A_CHAR
	beq et, r17, A_CHAR_HANDLER
	
	movia r17,D_CHAR
    beq et, r17, D_CHAR_HANDLER
	

	movia r17,W_CHAR
    beq et, r17, W_CHAR_HANDLER

	movia r17,X_CHAR
    beq et, r17, X_CHAR_HANDLER

	movia r17,K_CHAR
    beq et, r17, K_CHAR_HANDLER
	
	movia r17,BREAK
	beq et, r17, LED_OFF
	
	br LOOP1
	


	
W_CHAR_HANDLER:
	
AUDIO_BEEP:

	
	movi r18,48
	movia et, AUDIO
	movi r20, 86
	movia r16,0x60000000
	
WAIT:
	ldwio r19,4(et)
	andhi r17,r19,65280
	beq r17,r0,WAIT
	andhi r17,r19,255
	beq r17,r0,WAIT
WRITE:
	stwio r16,8(et)
	stwio r16,12(et)
	subi r18,r18,1
	bne r18,r0,WAIT
INVERT:
	movi r18,48
	sub r16,r0,r16
	subi r20,r20,1
	bne r20,r0,WAIT
	movia r16,ADDR_LED
	movi r17,0b1
	stwio r17,0(r16)
	
	movia r8,GPIO_JP1
	movia	 r13,0xffdffff0 #0000
	stwio	 r13, 0(r8) 
	
	br LOOP1
	
X_CHAR_HANDLER:

	AUDIO_BEEP1:

	
	movi r18,48
	movia et, AUDIO
	movi r20, 86
	movia r16,0x60000000
	
WAIT1:
	ldwio r19,4(et)
	andhi r17,r19,65280
	beq r17,r0,WAIT1
	andhi r17,r19,255
	beq r17,r0,WAIT1
WRITE1:
	stwio r16,8(et)
	stwio r16,12(et)
	subi r18,r18,1
	bne r18,r0,WAIT1
INVERT1:
	movi r18,48
	sub r16,r0,r16
	subi r20,r20,1
	bne r20,r0,WAIT1



	movia r16,ADDR_LED
	movi r17,0b10
	stwio r17,0(r16)
	
	movia r8,GPIO_JP1   
	movia	 r13,0xffdffffa  #1010
	stwio	 r13, 0(r8)
	
	movia r17,D_CHAR
	br LOOP1

A_CHAR_HANDLER:

	AUDIO_BEEP2:

	
	movi r18,48
	movia et, AUDIO
	movi r20, 86
	movia r16,0x60000000
	
WAIT2:
	ldwio r19,4(et)
	andhi r17,r19,65280
	beq r17,r0,WAIT2
	andhi r17,r19,255
	beq r17,r0,WAIT2
WRITE2:
	stwio r16,8(et)
	stwio r16,12(et)
	subi r18,r18,1
	bne r18,r0,WAIT2
INVERT2:
	movi r18,48
	sub r16,r0,r16
	subi r20,r20,1
	bne r20,r0,WAIT2



	movia r16,ADDR_LED
	movi r17,0b10
	stwio r17,0(r16)
	
	movia r8,GPIO_JP1   
	movia	 r13,0xffdffff1  #0001 right
	stwio	 r13, 0(r8)
	
	movia r17,W_CHAR
	br LOOP1

D_CHAR_HANDLER:

	AUDIO_BEEP3:

	
	movi r18,48
	movia et, AUDIO
	movi r20, 86
	movia r16,0x60000000
	
WAIT3:
	ldwio r19,4(et)
	andhi r17,r19,65280
	beq r17,r0,WAIT3
	andhi r17,r19,255
	beq r17,r0,WAIT3
WRITE3:
	stwio r16,8(et)
	stwio r16,12(et)
	subi r18,r18,1
	bne r18,r0,WAIT3
INVERT3:
	movi r18,48
	sub r16,r0,r16
	subi r20,r20,1
	bne r20,r0,WAIT3



	movia r16,ADDR_LED
	movi r17,0b10
	stwio r17,0(r16)
	
	movia r8,GPIO_JP1   
	movia	 r13,0xffdffff4  #0100
	stwio	 r13, 0(r8)
	
	movia r17,X_CHAR
	br LOOP1

K_CHAR_HANDLER:

	AUDIO_BEEP4:

	
	movi r18,48
	movia et, AUDIO
	movi r20, 86
	movia r16,0x60000000
	
WAIT4:
	ldwio r19,4(et)
	andhi r17,r19,65280
	beq r17,r0,WAIT4
	andhi r17,r19,255
	beq r17,r0,WAIT4
WRITE4:
	stwio r16,8(et)
	stwio r16,12(et)
	subi r18,r18,1
	bne r18,r0,WAIT4
INVERT4:
	movi r18,48
	sub r16,r0,r16
	subi r20,r20,1
	bne r20,r0,WAIT4



	movia r16,ADDR_LED
	movi r17,0b10
	stwio r17,0(r16)
	
	movia r8,GPIO_JP1   
	movia	 r13,MOTOR3  #0100
	stwio	 r13, 0(r8)
	
	movia r17,K_CHAR
	br LOOP1




LED_OFF:
	movia et, PS2_CONTROLLER_1
	ldwio r16, 0(et)
	
	#check if there are still chars to read
	movia et,0x8000
	and et,r16,et
	beq et,r0,LED_OFF

	movia r16,ADDR_LED
	stwio r0,0(r16)
	
	movia r8, GPIO_JP1
	movia r16, 0xffdfffff # mode: state     motor0: OFF
	stw r16, 0(r8)
	
	
	# stop motor
	movi r10, 2
	

	br EXIT
	
	
SERVE_TOUCHSENSOR:
	movia r16, ADDR_JP1_EDGE           # check edge capture register from GPIO JP1
	ldwio et, 0(r16)
	andhi r16, et, 0x0800              # mask bit 27 (sensor 0)  
	bne   r16, r0, CHANGE_DIRECTION    # change direction if sensor 0 interrupts, else keep checking sensor 1
	
	andhi r16, et, 0x1000              # mask bit 28 (sensor 1)  
	beq   r16, r0, ACKNOWLEDGE_JP1     # exit if sensor 0 did not interrupt
	

CHANGE_DIRECTION:
	movia et,GPIO_JP1
	ldw r16,(et)

	andi r16,r16,0b10
	beq r16,r0,TURN_REVERSE
	br TURN_FORWARD

TURN_REVERSE:
	
	movia    r10, 0x1         # save to the global direction
	

	br ACKNOWLEDGE_JP1

TURN_FORWARD:

	movia    r10, 0x0 
		
	
	
	br ACKNOWLEDGE_JP1

	

	
	

	
#Acknowlege the interrupt
ACKNOWLEDGE_JP1:
	movia r16, ADDR_JP1_EDGE
	movia et,0x18000000
	stwio et,0(r16)
	
	br EXIT


EXIT:
	
	#restore the previous state
	wrctl status,zero
	ldw et,12(sp)
	wrctl estatus,et
	ldw et,8(sp)
	ldw ea,16(sp)
	ldw r16,(sp)
	ldw r17,4(sp)
	ldw r18,20(sp)
	ldw r19,24(sp)
	ldw r20,28(sp)
	addi sp,sp,32
	subi ea,ea,4
	eret
	
	
	

