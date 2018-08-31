.equ ADDR_AUDIODACFIFO, 0xFF203040
.equ LED, 0xFF200000

.global _main 

_main:
	movia r2,ADDR_AUDIODACFIFO
	movia r4,LED
	ldwio r3,4(r2)      # Read fifospace register 
	andi  r3,r3,0xff    # Extract # of samples in Input Right Channel FIFO 
	beq   r3,r0,_start    # If no samples in FIFO, go back to start 
	
	# Echo to left channel 
	ldwio r21,8(r2)
	stwio r21,8(r2)      
	
	#writes to LEDs
	srli r22, r21, 24
	stwio r22, 0(r4)
	
	#Extracts highest bit for sound
	#andi r22, r21, 0b0
	#andhi r22, r21, 0b10000000
	#andhi r22, r21, 0b1

	#Instead of extracting the highest bit, I should see if it's greater than a certain thresholds
	#r21 stores the FIFO in, compare that to threshold
	
	movhi r10, %hi(805306367) #0x2fffffff
	ori r10, r10, %low(805306367) #0x2fffffff
	bgtu r21, r10, LOUD
	bltu r21, r10, QUIET

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
	
	movi r3, 0xffffffff
	beq r20, r3, MUSIC_YES
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
	
	CONT2:
	ldwio r3,12(r2)
	stwio r3,12(r2)     # Echo to right channel 
		
	br _start
