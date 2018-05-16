.data
hex_buf:	.word	0,0,0,0,0,0,0,0
digit_to_hex:	.word	'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
column_name:	.asciiz	"\ni\tpower(2,i)\tsquare(i)\tHexadecimal(i)\n"
message:	.asciiz	"Insert interger(i>=0): "
error1:		.asciiz	"\nInput number is too big --- input <= 30\n"
error2:		.asciiz	"\nInvalid input --- not a number\n"
error3:		.asciiz	"\nInput number must be greater or equal to 0\n"
error4:		.asciiz "\nNo input found\n"

.text
li $v0,4
la $a0,column_name	#print column name
syscall

L:	
li $v0,51		#input interger
la $a0,message
syscall
sgt $t0,$a0,30		#i > 30 -> too big 
beq $t0,1,Error1	#jump to error
nop
beq $a1,-1,Error2	#a1=-1 -> not a number
nop
beq $a1,-3,Error4	#a1=-3 -> no input found
nop
beq $a1,-2,done		#a1=-2 -> cancel
nop
slt $t0,$a0,$0		#i < 0
beq $t0,1,Error3	#jump to error
nop
add $s0,$a0,0		#store i to s0

#-------------------------------------
#print i
#-------------------------------------
li $v0,1
add $a0,$s0,0		#print i
syscall
li $v0,11
li $a0,'\t'		#print tab
syscall

#-------------------------------------
#print power(2,i)
#-------------------------------------
add $t0,$s0,0		#temp value of s0, t0 = i
add $a0,$zero,1		#a0 = 1
beq $t0,0,end_L1	#i = 0 -> 2^i = a0 = 1
nop
add $a0,$zero,2		#a0 = 2
beq $t0,1,end_L1	#i = 1 -> 2^i = a0 = 2
nop
L1:	add $t0,$t0,-1	#i = i-1
	mul $a0,$a0,2	#a0 = a0*2
	bne $t0,1,L1	#i = 1 end of loop
	nop
     #sll  $t1, $t2, 4
end_L1:
li $v0,1		#print a0 = 2^i
syscall
li $v0,11
li $a0,'\t'		#print tab
syscall

#-------------------------------------
#print square(i)
#-------------------------------------
mul $a0,$s0,$s0		#a0 = i*i
li $v0,1		#print i^2
syscall

li $v0,11
li $a0,'\t'		#print tab
syscall

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
	nop
	sw $t1,0($t3)	#value of address t3 = t1 
	nop
	srl $t0,$t0,4	#shift right t0 to take the previous 4 bits in the next loop
	add $t3,$t3,-4	#update address t3 to the previous position in hex_buf 
	bnez $t0,L3	#t0 = 0 end of loop
	nop
	
#print hex_buf
li $v0,11
li $a0,'0'
syscall			#print "0x"
li $a0,'x'
syscall

L4:	la $a0,hex_buf($t2)	
	li $v0,4
	syscall		#print value of hex_buf+t2
	add $t2,$t2,4	#update t2 to next element in hex_buf
	bne $t2,32,L4	#t2=8*4 end of loop
	nop

#reset hex_buf to 0
la $t5,hex_buf		#t5 = address of first element in hex_buf
la $t6,hex_buf+32	#t6 = address after last element in hex_buf
reset:	sw $0,0($t5)	#store 0 to value of address(t5)
	nop
	add $t5,$t5,4	#update t5 to next element in bin_buf
	bne $t5,$t6,reset
	nop		#t5 = t6 went thruogh all element -> end of loop


li $v0,11
li $a0,'\n'		#print newline
syscall
j L			#loop input interger again 
nop

#error
Error1:	li $v0,4
	la $a0,error1	#print string error -- too big number
	syscall
	j done
	nop
Error2:	li $v0,4
	la $a0,error2	#print string error -- not a number
	syscall
	j done
	nop
Error3:	li $v0,4
	la $a0,error3	#print string error -- input < 0
	syscall
	j done
	nop
Error4:	li $v0,4
	la $a0,error4	#print string error -- no input found
	syscall
done:
