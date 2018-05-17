.eqv KEY_CODE 0xFFFF0004 		# ASCII code from keyboard, 1 byte
.eqv KEY_READY 0xFFFF0000 		# =1 if has a new keycode ?
.eqv MASK_CAUSE_KEYBOARD 0x0000034 	# Keyboard Cause
# Auto clear after lw
.eqv SEVENSEG_LEFT 0xFFFF0011 		# Dia chi cua den led 7 doan trai.
# Bit 0 = doan a;
# Bit 1 = doan b; ...
# Bit 7 = dau .
.eqv SEVENSEG_RIGHT 0xFFFF0010 		# Dia chi cua den led 7 doan phai
.eqv COUNTER 0xFFFF0013 		# Time Counter
.eqv MASK_CAUSE_COUNTER 0x00000400 	# Bit 10: Counter interrupt
.data 
sample_text: .asciiz "bo mon ky thuat may tinh"
digital_led_number: .byte 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x67,0x77,0x7F,0x39,0x3F,0x79,0x71
msg_counter: .asciiz "Time inteval!\n"

.text
li $k0, KEY_CODE
li $k1, KEY_READY
#---------------------------------------------------------
# Enable interrupts you expect
#---------------------------------------------------------
# Enable the interrupt of TimeCounter of Digital Lab Sim
li $t4, COUNTER
sb $t4, 0($t4)
loop: 		nop
WaitForKey: 	lw $t8, 0($k1) 			# $t8 = [$k1] = KEY_READY
		beq $t8, $zero, WaitForKey 	# if $t8 == 0 then Polling
MakeIntR: 	teqi $t8, 1 			# if $t8 = 1 then raise an Interrupt
j loop

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# GENERAL INTERRUPT SERVED ROUTINE for all interrupts
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.ktext 0x80000180
IntSR: 
#--------------------------------------------------------
# Temporary disable interrupt
#--------------------------------------------------------
dis_int:	li $t4, COUNTER # BUG: must disable with Time Counter
		sb $zero, 0($t4)
#--------------------------------------------------------
# Processing
#--------------------------------------------------------
get_caus:	mfc0 $t1, $13 			# $t1 = Coproc0.cause
IsCount:	li $t2, MASK_CAUSE_COUNTER	# if Cause value confirm Counter..
		and $at, $t1,$t2
		beq $at,$t2, Counter_Intr
IsCountKey: 	li $t2, MASK_CAUSE_KEYBOARD	# if Cause value confirm Keyboard..
		and $at, $t1,$t2
		beq $at,$t2, Counter_Keyboard_Intr
others: 	j end_process 			# other cases

Counter_Keyboard_Intr:
ReadKey: 	lw $t9, 0($k0) 			# $t9 = [$k0] = KEY_CODE	
CheckKey:	lb $s2, sample_text($s1)	# load byte from asciiz (addr of sample_text)+$s1 to $s2
		addi $s1,$s1,1			# update 1 byte
		bne $s2,$t9,end_process		
		addi $s0,$s0,1			# if input char is right -> $s0=$s0+1 ($s0 is number of right input char)
		j end_process

Counter_Intr: 	addi $t3,$t3,1			# Processing Counter Interrupt
		bne $t3,20000,end_process	# $t3 < 2000
		li $v0, 4 			# Processing Counter Interrupt if t3 = 2000
		la $a0, msg_counter		# Print: "Time interval!"
		syscall
GetLedNumber:	addi $t5,$t5,10			# $t3 = 2000 counter interrupt 2000 times -> SetLed
		div $s0,$t5		
		mfhi $t6			#t6 so hang chuc
		mflo $t7			#t7 so hang don vi
		lb $t6,digital_led_number($t6)
		lb $t7,digital_led_number($t7)	
SetLed:		addi $a0,$t7,0			# set value for segments
		jal SHOW_7SEG_LEFT 		# show
		nop
		addi $a0,$t6,0			# set value for segments
		jal SHOW_7SEG_RIGHT 		# show
		nop
		add $s0,$0,$0			# reset number of right char ($s0)
		add $t3,$0,$0			# reset $t3 = 0
		j end_process
			
#---------------------------------------------------------------
# Function SHOW_7SEG_LEFT : turn on/off the 7seg
# param[in] $a0 value to shown
# remark $t0 changed
#---------------------------------------------------------------
SHOW_7SEG_LEFT: li $t0, SEVENSEG_LEFT 	# assign port's address
sb $a0, 0($t0) 				# assign new value
jr $ra
nop
#---------------------------------------------------------------
# Function SHOW_7SEG_RIGHT : turn on/off the 7seg
# param[in] $a0 value to shown
# remark $t0 changed
#---------------------------------------------------------------
SHOW_7SEG_RIGHT: li $t0, SEVENSEG_RIGHT # assign port's address
sb $a0, 0($t0) 				# assign new value
jr $ra
nop

end_process:
mtc0 $zero, $13 			# Must clear cause reg
en_int: 
#--------------------------------------------------------
# Re-enable interrupt
#--------------------------------------------------------
li $t4, COUNTER
sb $t4, 0($t4)
#--------------------------------------------------------
# Evaluate the return address of main routine
# epc <= epc + 4
#--------------------------------------------------------
next_pc:mfc0 $at, $14 			# $at <= Coproc0.$14 = Coproc0.epc
	addi $at, $at, 4 		# $at = $at + 4 (next instruction)
	mtc0 $at, $14 			# Coproc0.$14 = Coproc0.epc <= $at
return: eret 				# Return from exception

