.data 
	open: .asciiz "\nAuthor: thoatt"
	input: .asciiz "\nInput a string: "
	down: .asciiz "\n"
	errorNum: .asciiz "the number of character of the string must be divisible by 8\n"
	openFrame:  .asciiz "\n                    RAID 5 SIMULATOR\n      DISK 1                  DISK 2                  DISK 3\n ----------------        ----------------        ----------------\n"
	closeFrame: .asciiz "\n ----------------        ----------------        ----------------\n"
	string: .space 100
	openSquareBracket: .asciiz  "[[ "
	closeSquareBracket: .asciiz  "  ]]"
	printSpace: .asciiz "      "
	comma: .asciiz ","
	slash: "|"
	digit_to_hex: .word '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'
	hexBuf: .word 0,0
.text 

start: 	li $v0, 4				#for inputing
	la $a0, open
	syscall
	li $v0, 4
	la $a0, input
	syscall
	li $v0, 8
	la $a0, string
	la $a1, 100
	move $t0, $a0				#load value from $a0 to $t0
	syscall 
notout:	addi $t2, $t0, 0
	addi $s1, $t0, 0
	addi $s2, $0,0
checkerror:lb $t3, 0($s1)			#check if the number of character is divisible by 8
	addi $s1, $s1, 1			#count the number of characters
	addi $s2, $s2, 1
	bne $t3, $0, checkerror			#when meet \0, go to check if the number of characters if satisfied or not
	nop
	addi $s2, $s2, -2			# for quit \n
	addi $s3, $s2, 0
subtract:add $s2, $s2, -8			#subtract $s2 until $s2 is smaller than 8
	blt $s2 ,8, test
	j subtract
	nop
test: 	bne $s2, $0, error			#satisfied when $s2 is equal 0, if not print error mes and input again
	nop 
	j noterror
	nop
error: 	li $v0, 4
	la $a0, errorNum
	syscall
	j start
	nop
noterror:li $v0, 4
	la $a0, openFrame
	syscall
line1:                                 		#XOR block is right hand side
block1line1:					
	li $v0, 4
	la $a0, slash
	syscall
	li $v0, 4
	la $a0, printSpace
	syscall
	add $t7, $0, $0				#$t7 is to check if already having printed 4 bits of that block
print4bitsblock1line1:
	lb $t1, 0($t0)				#$t7 is from 1 to 4
	addi $t0, $t0, 1
	addi $t7, $t7, 1
	move $a0, $t1
	li $v0, 11
	syscall
	beq $t7, 4, block2line1			#if $t7 is equal 4 then print the second block
	nop
	bne $t1, $0, print4bitsblock1line1	
	nop
block2line1:					#print block 2 the same as the block 1
	add $t7, $0, $0
	li $v0, 4
	la $a0, printSpace
	syscall
	li $v0, 4
	la $a0, slash
	syscall
	li $v0, 4
	la $a0, printSpace
	syscall
	li $v0, 4
	la $a0, slash
	syscall
	li $v0, 4
	la $a0, printSpace
	syscall
print4bitsblock2line1:
	lb $t1, 0($t0)
	addi $t0, $t0, 1
	addi $t7, $t7, 1
	move $a0, $t1
	li $v0, 11
	syscall
	beq $t7, 4, block3line1
	nop
	bne $t1, $0, print4bitsblock2line1
	nop
block3line1:
	add $t7, $0, $0				#print "       |       [[ "
	li $v0, 4
	la $a0, printSpace
	syscall
	li $v0, 4
	la $a0, slash
	syscall
	li $v0, 4
	la $a0, printSpace
	syscall
	li $v0, 4
	la $a0, openSquareBracket
	syscall
print4bitsblock3line1:
	lb $s7, 0($t2)
	addi $t3, $t2, 4
	lb $s6, 0($t3)
	addi $t7, $t7, 1
	addi $t2, $t2, 1
	xor $s5, $s7, $s6		#calculate the each value of 4 bits in XOR block
					#print the result in hexadecimal number
L1:	la $s3, digit_to_hex
	la $s2, hexBuf + 4
	add $s1, $0, $0
	andi $s4, $s5, 0xf            	#store last 4 bits of $s5 to $s4, return 0->15
	add $s4, $s4, $s4
	add $s4, $s4, $s4
	add $s4, $s4, $s3		#s4 = 4 * s4 + address of digit_to_hex = position of element s4 in the array 
	lw $a0, 0($s4)
	sw $a0, 0($s2) 
	srl $s5, $s5, 4
	addi $s2, $s2, -4
	la $s3, digit_to_hex
	andi $s4, $s5, 0xf            	#store last 4 bits of $s5 to $s4, return 0->15
	add $s4, $s4, $s4
	add $s4, $s4, $s4
	add $s4, $s4, $s3		#s4 = 4 * s4 + address of digit_to_hex = position of element s4 in the array 
	lw $s4, 0($s4)
	sw $s4, 0($s2)
	la $a0, hexBuf($s1) 		#print hexBuf
	li $v0, 4
	syscall
	addi $s1, $s1, 4
	la $a0, hexBuf($s1)
	li $v0, 4
	syscall
	#reset hexBuf to 0,0
	la $a0, hexBuf
	sw $0, 0($a0)
	addi $a0, $a0, 4
	sw $0, 0($a0)
	
	#li $v0, 34
	#move $a0, $s5
	#syscall
	beq $t7, 4, endline1
	li $v0, 4
	la $a0, comma
	syscall
	j print4bitsblock3line1
	nop
endline1:li $v0, 4
	la $a0, closeSquareBracket
	syscall
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	beq $t1, $0, endAll					#check if ending string, go to endAll label
	nop
	addi $t0, $t0, -1
####################################################
line2:	li $v0, 4				#middle
	la $a0, down				#the same algorithm as the line 1 , just different position of the XOR block
	syscall
block1line2:	
	li $v0, 4
	la $a0, slash
	syscall
	li $v0, 4
	la $a0, printSpace
	syscall
	add $t7, $0, $0
print4bitsblock1line2:
	lb $t1, 0($t0)
	addi $t0, $t0, 1
	addi $t7, $t7, 1
	move $a0, $t1
	li $v0, 11
	syscall
	beq $t7, 4, block2line2
	nop
	bne $t1, $0, print4bitsblock1line2
	nop
block2line2:
	add $t7, $0, $0
	li $v0, 4
	la $a0, printSpace
	syscall
	li $v0, 4
	la $a0, slash
	syscall
	li $v0, 4
	la $a0, printSpace
	syscall
	li $v0, 4
	la $a0, openSquareBracket
	syscall
	addi $t2, $t2, 4
	
print4bitsblock2line2:
	lb $s7, 0($t2)
	addi $t3, $t2, 4
	lb $s6, 0($t3)
	addi $t7, $t7, 1
	addi $t2, $t2, 1
	xor $s5, $s7, $s6
	#convert to hex
L2:	la $s3, digit_to_hex
	la $s2, hexBuf + 4
	add $s1, $0, $0
	andi $s4, $s5, 0xf            	#store last 4 bits of $s5 to $s4, return 0->15
	add $s4, $s4, $s4
	add $s4, $s4, $s4
	add $s4, $s4, $s3		#s4 = 4 * s4 + address of digit_to_hex = position of element s4 in the array 
	lw $a0, 0($s4)
	sw $a0, 0($s2) 
	srl $s5, $s5, 4
	addi $s2, $s2, -4
	la $s3, digit_to_hex
	andi $s4, $s5, 0xf            	#store last 4 bits of $s5 to $s4, return 0->15
	add $s4, $s4, $s4
	add $s4, $s4, $s4
	add $s4, $s4, $s3		#s4 = 4 * s4 + address of digit_to_hex = position of element s4 in the array 
	lw $s4, 0($s4)
	sw $s4, 0($s2)
	la $a0, hexBuf($s1) 
	li $v0, 4
	syscall
	addi $s1, $s1, 4
	la $a0, hexBuf($s1)
	li $v0, 4
	syscall
	#reset hexBuf
	la $a0, hexBuf
	sw $0, 0($a0)
	addi $a0, $a0, 4
	sw $0, 0($a0)
	#_______________________
	beq $t7, 4, block3line2
	li $v0, 4
	la $a0, comma
	syscall
	j print4bitsblock2line2
	nop
block3line2:
	li $v0, 4
	la $a0, closeSquareBracket
	syscall
	add $t7, $0, $0
	li $v0, 4
	la $a0, printSpace
	syscall
	li $v0, 4
	la $a0, slash
	syscall
	li $v0, 4
	la $a0, printSpace
	syscall
print4bitsblock3line2:
	lb $t1, 0($t0)
	addi $t0, $t0, 1
	addi $t7, $t7, 1
	move $a0, $t1
	li $v0, 11
	syscall
	beq $t7, 4, endline2
	nop
	bne $t1, $0, print4bitsblock3line2
	nop
endline2:add $t7, $0, $0
	li $v0, 4
	la $a0, printSpace
	syscall
	li $v0, 4
	la $a0, slash
	syscall
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	beq $t1, $0, endAll
	nop
	addi $t0, $t0, -1
######################################################
line3: 	li $v0, 4				#left
	la $a0, down
	syscall
block1line3:li $v0, 4
	la $a0, openSquareBracket
	syscall
	add $t7, $0, $0
	addi $t2, $t2, 4
print4bitsblock1line3:
	lb $s7, 0($t2)
	addi $t3, $t2, 4
	lb $s6, 0($t3)
	addi $t7, $t7, 1
	addi $t2, $t2, 1
	xor $s5, $s7, $s6
	
	#convert to hex
L3:	la $s3, digit_to_hex
	la $s2, hexBuf + 4
	add $s1, $0, $0
	andi $s4, $s5, 0xf            	#store last 4 bits of $s5 to $s4, return 0->15
	add $s4, $s4, $s4
	add $s4, $s4, $s4
	add $s4, $s4, $s3		#s4 = 4 * s4 + address of digit_to_hex = position of element s4 in the array 
	lw $a0, 0($s4)
	sw $a0, 0($s2) 
	srl $s5, $s5, 4
	addi $s2, $s2, -4
	la $s3, digit_to_hex
	andi $s4, $s5, 0xf            	#store last 4 bits of $s5 to $s4, return 0->15
	add $s4, $s4, $s4
	add $s4, $s4, $s4
	add $s4, $s4, $s3		#s4 = 4 * s4 + address of digit_to_hex = position of element s4 in the array 
	lw $s4, 0($s4)
	sw $s4, 0($s2)
	la $a0, hexBuf($s1) 
	li $v0, 4
	syscall
	addi $s1, $s1, 4
	la $a0, hexBuf($s1)
	li $v0, 4
	syscall
	#reset hexBuf
	la $a0, hexBuf
	sw $0, 0($a0)
	addi $a0, $a0, 4
	sw $0, 0($a0)
	
	
	beq $t7, 4, block2line3
	li $v0, 4
	la $a0, comma
	syscall
	j print4bitsblock1line3
	nop
block2line3:li $v0, 4
	la $a0, closeSquareBracket
	syscall
	add $t7, $0, $0
	addi $t2, $t2, 4
	li $v0, 4
	la $a0, printSpace
	syscall
	li $v0, 4
	la $a0, slash
	syscall
	li $v0, 4
	la $a0, printSpace
	syscall
print4bitsblock2line3:
	lb $t1, 0($t0)
	addi $t0, $t0, 1
	addi $t7, $t7, 1
	move $a0, $t1
	li $v0, 11
	syscall
	beq $t7, 4, block3line3
	nop
	bne $t1, $0, print4bitsblock2line3
	nop
block3line3:add $t7, $0, $0				#print "      |        |        "
	li $v0, 4
	la $a0, printSpace
	syscall
	li $v0, 4
	la $a0, slash
	syscall
	li $v0, 4
	la $a0, printSpace
	syscall
	li $v0, 4
	la $a0, slash
	syscall
	li $v0, 4
	la $a0, printSpace
	syscall
	
print4bitsblock3line3:
	lb $t1, 0($t0)
	addi $t0, $t0, 1
	addi $t7, $t7, 1
	move $a0, $t1
	li $v0, 11
	syscall
	beq $t7, 4, endline3
	nop
	bne $t1, $0, print4bitsblock3line3
	nop
endline3:add $t7, $0, $0
	li $v0, 4
	la $a0, printSpace
	syscall
	li $v0, 4
	la $a0, slash
	syscall
	addi $t0, $t0, 1
	lb $t1, 0($t0)
	beq $t1, $0, endAll			#if the string ends, go to endAll label and exit
	nop
	addi $t0, $t0, -1
	li $v0, 4				#print \n
	la $a0, down
	syscall
	j line1					#if not end, go to line 1
	nop
#################################################
endAll: li $v0, 4
	la $a0, closeFrame
	syscall