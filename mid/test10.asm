.data 
	i: .space 32
	power: .space 32
	resquare: .space 32
	rehexa: .space 32
	Message: .asciiz "Input an integer: "
	mesnum: .asciiz "i"
	mespow: .asciiz "power(2,i)"
	mesbin: .asciiz "square(i)"
	meshexa: .asciiz "Hexadecimal"
	mes: .asciiz "0x"
	mescont: .asciiz "Continue?"
	down: .asciiz "\n"
	tab: .asciiz "                   "
	meserrorinput: .asciiz "invalid input"
.text 
print:	li $v0,4		
	la $a0, mesnum            #in decimal
	syscall	
	li $v0,4		#tab
	la $a0, tab
	syscall	
	li $v0,4		#in mespow
	la $a0, mespow
	syscall	
	li $v0,4		#tab
	la $a0, tab
	syscall	
	li $v0,4		#in mesbin
	la $a0, mesbin
	syscall	
	li $v0,4		#tab
	la $a0, tab
	syscall	
	li $v0,4		#in meshexa
	la $a0, meshexa
	syscall	
	li $v0,4		#in \n
	la $a0, down
	syscall	
start:
	li $v0, 51
	la $a0, Message                    #message cho nhap so
	syscall
	bne $a1,0,error	#a1 != 0 -> no input -> input again
        nop
        add $s3,$0,$a0
        addi $s3,$s3,-30            #warning for overflow
        bgtz $s3,error
        nop
	add $s2,$0,$a0
	add $s5,$0,$a0	
	j rightinput
	nop
error:	li $v0,4	#
	la $a0, meserrorinput	#in meserrorinput
	syscall
	li $v0,4	#
	la $a0, down	#in \n
	syscall
	j print
	nop
rightinput:                            #neu nhap dung 
	add $s2, $0, $a0
	add $s3, $0, $a0
	add $s4, $0, $a0
	add $s5, $0, $a0
printinput:	
	li $v0, 1                      #in so da nhap
	add $a0, $s4, $0
	syscall 
	li $v0,4		#tab
	la $a0, tab
	syscall	
#tinh 2^i
calpower:
	beq $s2, $0, zeropow
	nop
	li $a0, 1
powloop:
	li $t0, 2
	mul $t1, $a0, $t0
	mfhi $t2
	mflo $t3
	ori $a0, $t2, 0
	ori $a0, $t3, 0
	addi $s2, $s2, -1
	bne $s2, $0, powloop
	nop
exit: 	j printpower
	nop
zeropow:
	addi $a0, $0, 1
printpower:
	li $v0, 1
	syscall 
	li $v0,4
	la $a0, tab
	syscall
	
#tinh binh phuong
calsquare:
	mul $t1, $s3, $s3
	mfhi $t2
	mflo $t3
	ori $a0, $t2, 0
	ori $a0, $t3, 0
printsquare:
	li $v0, 1
	syscall 
	li $v0,4		#
	la $a0, tab
	syscall	
#doi sang he 16
tohexa:				#
	li $t1,16		#
	la $s6, rehexa		#
	la $s7, rehexa		#
	#add $s5,$0,$a0		#
loophexa:
	divu $s5,$t1		#
	mfhi $s1
	mflo $s5		#
	sw $s1,0($s6)
	addi $s6,$s6,4		#
	bgtz $s5,loophexa	#
	subi $s6,$s6,4
	li $v0,4		#
	la $a0, tab
	syscall			#
#in gia tri vua nhap sang he 16
printhexa:
	li $v0,4		#
	la $a0, mes
	syscall	
	lw $s1,0($s6)		#load dia gia tri o dia chi dang luu o s6 vao s1
	li $t1,10		#
	li $t2,11		#
	li $t3,12		#gan cac truong hop so du >9
	li $t4,13		#
	li $t5,14		#
	li $t6,15		#
	beq $s1,$t1,case_10
	nop	#
	beq $s1,$t2,case_11	#
	nop
	beq $s1,$t3,case_12	#
	nop
	beq $s1,$t4,case_13	#nhay den cac truong hop tuong ung vs gia tri cua s1
	nop
	beq $s1,$t5,case_14	#
	nop
	beq $s1,$t6,case_15	#
	nop
	b default		#neu ko thi nhay den default
	nop		#neu ko thi nhay den default
#in ra khi gia tri la 10
case_10:
	li $v0, 11
	li $a0,'A'
	syscall
	b end_switch
#in ra khi gia tri la 11
case_11:
	li $v0, 11
	li $a0,'B'
	syscall
	b end_switch
#in ra khi gia tri la 12
case_12:
	li $v0, 11
	li $a0,'C'
	syscall
	b end_switch
#in ra khi gia tri la 13
case_13:
	li $v0, 11
	li $a0,'D'
	syscall
	b end_switch
#in ra khi gia tri la 14
case_14:
	li $v0, 11
	li $a0,'E'
	syscall
	b end_switch
#in ra khi gia tri la 15
case_15:
	li $v0, 11
	li $a0,'F'
	syscall
	b end_switch
#in ra so day neu gia tri cua no <=9
default:
	li $v0, 1
	add $a0,$s1,$0
	syscall
	b end_switch
#xet xem da in het ket qua chua?
end_switch:
	subi $s6,$s6,4
	sub $s4,$s6,$s7
	bgez $s4,printhexa    #neu chua het tiep tuc in
	nop
end_hexa:
	li $v0,4
	la $a0, down
	syscall
continue:
	li $v0,50
	la $a0,mescont
	syscall
	beq $a0,$0,start
	nop
end: 
	
