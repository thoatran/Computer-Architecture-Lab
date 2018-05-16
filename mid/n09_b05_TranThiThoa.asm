.data
rebinary: .space 32
rehexa: .space 32
Message: .asciiz "Input an integer: "
mesdec: .asciiz "Decimal : "
mesbin: .asciiz "Binary : "
meshexa: .asciiz "Hexadecimal : "
mes: .asciiz "0x"
mescont: .asciiz "Continue?"
down: .asciiz "\n"
meserrorinput: .asciiz "invalid input"
.text
start:
	li $v0, 51
	la $a0, Message
	syscall
	bne $a1,0,error	#a1 != 0 -> no input -> input again
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
	j start	
	nop
rightinput:li $v0,4	#
	la $a0, mesdec	#in mesdec
	syscall
	add $a0,$0,$s2
	li $v0,1	#in decimal
	syscall
	li $v0,4	#
	la $a0, down	#in \n
	syscall

tobinary:li $t1,2	#chon base (he nhi phan)
	la $s0, rebinary	#load dia chi nho ket qua doi tu dec -> bin
	la $s3, rebinary	#load dia chi nho ket qua doi tu dec -> bin
	
loopbin:divu $s2,$t1	#chia so do cho base (2)
	mfhi $s1	#lay phan du luu vao s1
	mflo $s2	#lay phan thuong luu vao s2
	sw $s1,0($s0)	#luu gia tri s1 vao o nho co dia chi dang dc luu o s0
	addi $s0,$s0,4	#tang dia chi o nho len 4(4 byte)
	bgtz $s2,loopbin  #neu s2 > 0 thi lap(thuong > 0)
	nop
	subi $s0,$s0,4	#lui bien luu dia chi ve 4 byte de bat dau in(do khi den lenh nay thi s0 dang bj cong thua len 4byte)
	li $v0,4	#
	la $a0, mesbin	#in mesbin
	syscall		##i

printbin:li $v0,1	#goi lenh syscall (1 la de in so)
	lw $s1,0($s0)	#luu gia tri cua dia chi dang luu o s0 vao s1
	add $a0,$s1,$0	#chuyen gia tri tu s1 sang a0 de in
	syscall		#in
	subi $s0,$s0,4	#lui o dia chi 4 byte
	sub $s4,$s0,$s3	#so sanh xem dia chi o s0 da ve o dia chi ban dau chua?
	bgez $s4,printbin#neu chua thi tiep tuc lap

end_bin:li $v0,4
	la $a0, down
	syscall
#doi sang he 16
tohexa: li $t1,16		#
	la $s6, rehexa		#
	la $s7, rehexa		#
	#add $s5,$0,$a0		#
loophexa:divu $s5,$t1		#
	mfhi $s1
	mflo $s5		#
	sw $s1,0($s6)
	addi $s6,$s6,4		#tuong tu ben tren
	bgtz $s5,loophexa	#
	subi $s6,$s6,4
	li $v0,4		#
	la $a0, meshexa
	syscall			#
#in gia tri vua nhap sang he 16
	li $v0,4		#
	la $a0, mes
	syscall	
printhexa:lw $s1,0($s6)		#load dia gia tri o dia chi dang luu o s6 vao s1
	li $t1,10		#
	li $t2,11		#
	li $t3,12		#gan cac truong hop so du >9
	li $t4,13		#
	li $t5,14		#
	li $t6,15		#
	beq $s1,$t1,case_10
	nop	
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
	nop
#in ra khi gia tri la 10
case_10:li $v0, 11
	li $a0,'A'
	syscall
	b end_switch
	nop
#in ra khi gia tri la 11
case_11:li $v0, 11
	li $a0,'B'
	syscall
	b end_switch
	nop
#in ra khi gia tri la 12
case_12:li $v0, 11
	li $a0,'C'
	syscall
	b end_switch
	nop
#in ra khi gia tri la 13
case_13:li $v0, 11
	li $a0,'D'
	syscall
	b end_switch
	nop
#in ra khi gia tri la 14
case_14:li $v0, 11
	li $a0,'E'
	syscall
	b end_switch
	nop
#in ra khi gia tri la 15
case_15:li $v0, 11
	li $a0,'F'
	syscall
	b end_switch
	nop
#in ra so day neu gia tri cua no <=9
default:li $v0, 1
	add $a0,$s1,$0
	syscall
	b end_switch
	nop
#xet xem da in het ket qua chua?
end_switch:subi $s6,$s6,4
	sub $s4,$s6,$s7
	bgez $s4,printhexa 
	nop   
	#neu chua het tiep tuc in

end_hexa:li $v0,4
	la $a0, down
	syscall
continue:li $v0,50
	la $a0,mescont #message neu nguoi dung muon tiep tuc nhap 
	syscall
	beq $a0,$0,start
	nop
end: 
	
