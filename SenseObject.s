.equ ADDR_JP2_DATA, 0xFF200070
.equ ADDR_JP2_DIR, 0xFF200074
.equ ADDR_JP2_IE, 0xFF200078
.equ ADDR_JP2_EDGE, 0xFF20007C
.equ IRQ_JP2, 0x00001000
.equ ADDR_LED, 0xFF200000  

# use gpio 2
# if senser output == 1, detects the object
# LED will be turned off

# hardware connection: D0 to output from arduino, D1 to GND, D3 to 3.3V

# things to modify in main: ctrl3 enable irq12

.global _sense
_sense:

    # set up stack
    subi sp, sp, 24
	stw  r5, 0(sp)
	stw  r7, 4(sp)
    stw  r9, 8(sp)
    stw  r2, 12(sp)
	stw  r3, 16(sp)
	stw  r12, 20(sp)
	
	movia r5, ADDR_JP2_DATA
	movia r7, ADDR_LED


    # write to GPIO_JP2
    movia r9, 0xFFFFFFFF
	stwio r9, 4(r5)
	 
	# initialize with 0
	movia r9, 0x0
	stwio r9, (r5)
	 
	 
    # read from GPIO_JP2
	movia r9, 0x0
	stwio r9, 4(r5)
	 
	# load value inside
	ldwio r2, (r5)
	 
	# mask and check the sensor output
	andi r12, r2, 0b1 
	bne r0, r12, LED_OFF  # when no object detected
		
	# turn on LED when object is detected
	movia r2, 0x1
	stwio r2, 0(r7)
	
	
	####### Interrupt
	
INT:	
	movia r2, ADDR_JP2_IE
    movi  r3, 0b1
    stwio r3, 0(r2)  # Enable interrupts on D0 pin
	
	
	# restore stack
	ldw  r5, 0(sp)
	ldw  r7, 4(sp)
    ldw  r9, 8(sp)
    ldw  r2, 12(sp)
	ldw  r3, 16(sp)
	ldw  r12, 20(sp)
	addi sp, sp, 24
	
	ret	
	
LED_OFF:
	stwio r0, 0(r7)
	
   br INT
