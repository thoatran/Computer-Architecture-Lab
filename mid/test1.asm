.data
bin_buf: 	.word	0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
hex_buf:	.word	0,0,0,0,0,0,0,0
digit_to_hex:	.word	'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
decimal:	.asciiz	"Decimal: "
hex:		.asciiz	"\nConvert to hexadecimal: "
binary:		.asciiz	"\nConvert to binary: "

.text
li $v0,4
la $a0,decimal		#print sting "Decimal: "
syscall
li $v0,5		#insert decimal
syscall
add $s0,$v0,0		#decimal = s0


#----------------------------------------
#convert to binary and store to bin_buf
#----------------------------------------
add $t0,$s0,0		#t0 = s0
la $t3,bin_buf+124	#load address of last element in bin_buf 4*32bits-4
add $t2,$zero,0		#t2 = 0

L1:	and $t1,$t0,1	#t1 = t1 & 000...001 --> store last bit in t1
	add $t1,$t1,'0'	#convert from digit 1 or 0 to char '1' or '0'
	sw $t1,0($t3)	#store t1 to value of address (t3)(value that store in data segment) initialize at the last position of bin_buf
	srl $t0,$t0,1	#shift right t0 to take the previous bit in the next loop
	add $t3,$t3,-4	#update address t3 to the previous position in bin_buf 
	bnez $t0,L1	#t0 = 0 end of loop
	nop

li $v0,4
la $a0,binary		#print string "...binary: "
syscall

#print bin_buf
L2:	la $a0,bin_buf($t2)	
	li $v0,4
	syscall		#print value of bin_buf+t2
	add $t2,$t2,4	#update t2 to next element in bin_buf
	bne $t2,128,L2	#t2=32bits*4 end of loop
	nop


#-------------------------------------
#convert to hex and store to hex_buf
#-------------------------------------
add $t0,$s0,0		#t0 = s0
la $t3,hex_buf+28	#load address of last element in hex_buf 4*8-4
la $t4,digit_to_hex	#load address of digit_to_hex
add $t2,$zero,0		#t2 = 0

L3: 	and $t1,$t0,0xf	#t1 = t1 & 00...01111 -> store last 4 bits in t1 return 0->15
	add $t1,$t1,$t1	
	add $t1,$t1,$t1	#t1 = 4*t1
	add $t1,$t1,$t4	#t1 = 4*t1 + address of digit_to_hex = address of element at position t1 in array (4 * 10 + t4 -> address t4[10])
	lw $t1,0($t1)	#t1 = value of address t1 (register t1 = value of t4[10] = 'A' )
	sw $t1,0($t3)	#value of address t3 = t1 
	srl $t0,$t0,4	#shift right t0 to take the previous 4 bits in the next loop
	add $t3,$t3,-4	#update address t3 to the previous position in hex_buf 
	bnez $t0,L3	#t0 = 0 end of loop
	nop
	
li $v0,4
la $a0,hex		#print string "...hexadecimal: "
syscall

#print hex_buf
L4:	la $a0,hex_buf($t2)	
	li $v0,4
	syscall		#print value of hex_buf+t2
	add $t2,$t2,4	#update t2 to next element in hex_buf
	bne $t2,32,L4	#t2=32bits*4 end of loop
	nop
