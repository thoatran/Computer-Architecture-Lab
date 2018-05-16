# =========== READ MNUMBER IN VIETNAMESE ==============
# Input : integer number from 0 to 999.999.999
# Ideal : Split number into 3 part and read them separately.
#			Eg: Number: 123.456.789 will be devided into 3 parts: 123, 456, 789
# Author: Viet Anh Nguyen (vietanhdev)

.data
	msg0: .asciiz    "Nhap mot so tu nhien (0 <= n <= 999.999.999): "
	msg1: .asciiz    "Vui long nhap so tu nhien tu 0 den 999.999.999"
	
	msg2: .asciiz    "Doc so: "
	
	trieu: .asciiz    " trieu"
	tram: .asciiz    " tram"
	nghin: .asciiz    " nghin"
	
	khong: .asciiz    " khong"
	mot: .asciiz    " mot"
	hai: .asciiz    " hai"
	ba: .asciiz    " ba"
	bon: .asciiz    " bon"
	nam: .asciiz    " nam"
	sau: .asciiz    " sau"
	bay: .asciiz    " bay"
	tam: .asciiz    " tam"
	chin: .asciiz    " chin"
	muoi: .asciiz    " muoi"
	linh: .asciiz    " linh"

.text
.globl main

main:

	# *** Save constants into s1, s2
	li $s1, 1000
	li $s2, 10
	# Separated parts of the number. Each part is a group of 3 digits.
	# => Split from right to left
	# $s0 -> $s5$s6$s7

	# PHASE 1: INPUT THE DATA
	# =============================================
	# Get the input number and save to $s0
	jal get_input_number
	nop
	
	
	# PHASE 2: PROCESS THE DATA
	# =============================================
	# *** Split into parts
	addi $t0, $s0, 0 # copy $s0 to tmp variable $t0
	
	div $t0, $s1
	mfhi $s7 # get quotient
	mflo $t0 # get remainder
	
	div $t0, $s1
	mfhi $s6 # get quotient
	mflo $t0 # get remainder
	
	div $t0, $s1
	mfhi $s5 # get quotient
	
	
	# PHASE 3: READ THE NUMBER
	# =============================================
	# Doc so:
	li $v0, 4 
	la $a0, msg2
	syscall
	
	beq $s0, $zero, doc_so_khong
	nop
	
	# Part 1:
	part1:
	beq $s5, $zero, end_part1
	nop
	
	addi $a0, $s5, 0
	jal read_part
	nop
	
	li $v0, 4
	la $a0, trieu
	syscall
	
	end_part1:
	
	# Part 2:
	part2:
	beq $s6, $zero, end_part2
	nop
	
	addi $a0, $s6, 0
	jal read_part
	nop
	
	li $v0, 4
	la $a0, nghin
	syscall
	
	end_part2:
	
	# Part 3:
	
	# *** SPECIAL CASE
	# Xu li rieng khi so hang tram va hang chuc bang 0
	# 1001: khong the doc la: "Mot nghin mot"
	# Ma phai la: "Mot nghin khong tram linh mot"
	addi $t0, $s7, 0
	
	div $t0, $s2
	mfhi $t2 # get quotient
	mflo $t0 # get remainder
	
	div $t0, $s2
	mfhi $t1 # get quotient
	mflo $t0 # get remainder
	
	add $t4, $s5, $s6
	beq $t4, $zero, part3
	beq $t2, $zero, part3
	
	# ================== TRAM =====================
	doc_hang_tram1:
	beq $t0, 0, read_khong_tram # not reading if equal to 0
	nop

	addi $a0, $t0, 0
	jal read_digit
	nop
	
	li $v0, 4
	la $a0, tram
	syscall
	
	b end_doc_hang_tram1
	
	read_khong_tram:
	li $v0, 4
	la $a0, khong
	syscall
	li $v0, 4
	la $a0, tram
	syscall
	
	end_doc_hang_tram1:
	
	
	# ================== CHUC =====================
	doc_hang_chuc1:
	beq $t1, 0, doc_linh1 # read "linh"
	nop
	
	beq $t1, 1, doc_muoi1 # reading "muoi" instead of "mot"
	nop
	
	addi $a0, $t1, 0
	jal read_digit
	nop
	
	doc_muoi1:
		li $v0, 4
		la $a0, muoi
		syscall
		
	b end_doc_hang_chuc1
			
	doc_linh1:
		li $v0, 4
		la $a0, linh
		syscall
	
	end_doc_hang_chuc1:

	addi $s7, $t2, 0
	
	# ============================
	
	
	part3:
	beq $s7, $zero, end_part3
	nop
	
	addi $a0, $s7, 0
	jal read_part
	nop
	
	end_part3:
	
	
	j end_of_program
	nop
	
	doc_so_khong:
	li $v0, 4
	la $a0, khong
	syscall
	
	end_of_program:
	
	# Exit the program
	j exit0
	nop
	

# Read a part of the number
# Get input part from $a0 and print the text form (read the number)
# use: $t0, $t1, $t2
#		$s3 (save $ra)
read_part:
	addi $t0, $a0, 0
	
	div $t0, $s2
	mfhi $t2 # get quotient
	mflo $t0 # get remainder
	
	div $t0, $s2
	mfhi $t1 # get quotient
	mflo $t0 # get remainder

	# ================== TRAM =====================
	doc_hang_tram:
	beq $t0, 0, end_doc_hang_tram # not reading if equal to 0
	nop

	addi $s3, $ra, 0 # Save $ra
	addi $a0, $t0, 0
	jal read_digit
	nop
	addi $ra, $s3, 0 # Restore $ra
	
	li $v0, 4
	la $a0, tram
	syscall
	end_doc_hang_tram:
	
	
	# ================== CHUC =====================
	doc_hang_chuc:
	beq $t1, 0, end_doc_hang_chuc # not reading if equal to 0
	nop
	
	beq $t1, 1, doc_muoi # reading "muoi" instead of "mot"
	nop
	
	addi $s3, $ra, 0 # Save $ra
	addi $a0, $t1, 0
	jal read_digit
	nop
	addi $ra, $s3, 0 # Restore $ra
	
	doc_muoi:
		li $v0, 4
		la $a0, muoi
		syscall
	
	end_doc_hang_chuc:
	
	
	# ================== DON VI =====================
	doc_hang_don_vi:
	
		# hang chuc bang 0
		bne $t1, $zero, doc_binh_thuong
		nop		
		# hang tram khac 0
		beq $t0, $zero, doc_binh_thuong
		nop
		
		beq $t2, $zero, end_doc_hang_don_vi
		
		# Print "linh"
		li $v0, 4
		la $a0, linh
		syscall
	
		doc_binh_thuong:
		
		beq $t2, $zero, end_doc_hang_don_vi
		
		addi $s3, $ra, 0 # Save $ra
		addi $a0, $t2, 0
		jal read_digit
		nop
		addi $ra, $s3, 0 # Restore $ra
	end_doc_hang_don_vi:
	

	jr $ra
	nop


# Read a digit of the number
# input: $a0
# use: $t7
# ouput: screen
read_digit:
	li $t7, 0
	beq $a0, $t7, case_0
	li $t7, 1
	beq $a0, $t7, case_1
	li $t7, 2
	beq $a0, $t7, case_2 
	li $t7, 3
	beq $a0, $t7, case_3 
	li $t7, 4
	beq $a0, $t7, case_4 
	li $t7, 5
	beq $a0, $t7, case_5 
	li $t7, 6
	beq $a0, $t7, case_6 
	li $t7, 7
	beq $a0, $t7, case_7
	li $t7, 8
	beq $a0, $t7, case_8 
	li $t7, 9
	beq $a0, $t7, case_9
	b default
case_0:
	li $v0, 4
	la $a0, khong
	syscall
	b default
case_1:
	li $v0, 4
	la $a0, mot
	syscall
	b default
case_2:
	li $v0, 4
	la $a0, hai
	syscall
	b default
case_3:
	li $v0, 4
	la $a0, ba
	syscall
	b default
case_4:
	li $v0, 4
	la $a0, bon
	syscall
	b default
case_5:
	li $v0, 4
	la $a0, nam
	syscall
	b default
case_6:
	li $v0, 4
	la $a0, sau
	syscall
	b default
case_7:
	li $v0, 4
	la $a0, bay
	syscall
	b default
case_8:
	li $v0, 4
	la $a0, tam
	syscall
	b default
case_9:
	li $v0, 4
	la $a0, chin
	syscall
	b default

default:
	jr $ra
	nop

# Input number -> $s0
get_input_number:
	li $v0, 51
	la $a0, msg0
	syscall
	
	# If choose Cancel, exit the program
   	beq $a1, -2, exit0
   	nop
	# Check valid for mark
   	bne $a1, 0, error_on_get_input_number
   	nop
   	# Check < 0
   	slt $t0, $a0, $zero
   	bne $t0, 0, error_on_get_input_number
   	nop
   	# Check > 999.999.999
   	li $t2, 999999999
   	slt $t0, $t2, $a0
   	bne $t0, 0, error_on_get_input_number
   	nop
	
	addi $s0, $a0, 0
	
	jr $ra
	nop

error_on_get_input_number:
	li $v0, 55
	la $a0, msg1
	syscall
	j get_input_number
	nop


# Exit the program
exit0:


	
	
