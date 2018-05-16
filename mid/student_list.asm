# =========== STUDENT LIST ==============
# Read a list of student and their mark => Sort asccending by mark => Print the result
# Author: Viet Anh Nguyen (vietanhdev)

.data
	studentList: .space 3200
	
	# For sorting algorithm
	sortedOrder: .space	400 # Save int value : sort order of student
	
	msge: .asciiz    "Error happened!"
	msg1: .asciiz    "Number of student: "
	msg2: .asciiz	 "Enter student name: "
	msg3: .asciiz	 "Please input a valid name <= 28 characters: "
	msg4: .asciiz	 "Input mark: "
	msg5: .asciiz	 "Please input a valid mark! Mark must be an int value from 0 to 10."
	msg6: .asciiz	 "STUDENT LIST - UNSORTED\n"
	msg7: .asciiz	 "+=========+===========================+\n"
	msg8: .asciiz	 "+===Mark==+======StudentName==========+\n"
	msg9: .asciiz    "     "
	msg10: .asciiz    "Number of student must be in range 0 to 100"
	msg11: .asciiz	 "STUDENT LIST - SORTED\n"

.text
.globl main

main:

	# PHASE 1: INPUT THE DATA
	# =============================================
	
	# Input number of student -> $s0
	jal get_num_of_student
	nop
	
	# For-loop to input all student data
	li $t0,1 # Reset count variable $t0
	
	# Use $s1 as pointer for array studentList
	la  $s1, studentList
	
	loop:
    bgt $t0, $s0, endloop # 

    
    # Read student info
    
    # Student Name
    input_name:
    li $v0, 54
	la $a0, msg2
	addi $a1, $s1, 0
	la $a2, 28 # Limit length of student name: 28
	syscall
	
	# Check valid for name
   	bne $a1, 0, reinput_name_dialog
   	nop
	
	# Mark
	input_mark:
	li $v0, 51
	la $a0, msg4
	syscall
	
	# If choose Cancel while input mark, exit the program
   	beq $a1, -2, exit0
   	nop
	# Check valid for mark
   	bne $a1, 0, reinput_mark_dialog
   	nop
   	# Check < 0
   	slt $t1, $a0, $zero
   	bne $t1, 0, reinput_mark_dialog
   	nop
   	# Check > 10
   	li $t2, 10
   	slt $t1, $t2, $a0
   	bne $t1, 0, reinput_mark_dialog
   	nop
   	
   	# Save mark into memory
   	sw $a0, 28($s1)
   	
    
    # Increase count variable
    addi $t0, $t0, 1
    
    # Increase student data pointer
    addi $s1, $s1, 32
    
    j loop
    nop
    
    # Re-input name plz
    reinput_name_dialog:
    li $v0, 55
	la $a0, msg3
	syscall
	j input_name
    nop
    
    # Re-input mark plz
    reinput_mark_dialog:
    li $v0, 55
	la $a0, msg5
	syscall
	j input_mark
    nop
    
	endloop:
	
	
	# PHASE 2: PROCESS THE DATA
	# =============================================
	
	# Print Unsorted list
	jal print_student_list
	nop
	
	# *** Sort student list by mark // ASC
	# Sort and write sorted order to sortedOrder
	# Algorithm: For each grade level 0 -> 10, 
	# go from beginning to the end of the student list,
	# find students with current grade and push their index
	# to sortedOrder
	li $t0, 0 # current grade level
	la $t1, sortedOrder # get address of sorted order
	
	loop1:
	beq $t0, 11, endloop1 # gone over all mark level
	nop
	
	li $t3, 0 # index of sutdent
	la $t2, studentList # get address of student list
	loop2:
		beq $t3, $s0, endloop2 # exit loop when $t3 goes to number of student $s0
		nop
		
		# get mark of current student and save to t4
		lw $t4, 28($t2)
		
		# compare mark of student to current mark.
		# if equal, push student index to the sorting list
		bne $t4, $t0, skip_student
		nop
		
		sw $t3, 0($t1) # store index of current student to sorting list
		addi $t1, $t1, 4
		
		skip_student:
		
		addi $t3, $t3, 1
		addi $t2, $t2, 32
		j loop2
		nop
	endloop2:
	
	addi $t0, $t0, 1
	j loop1
	nop
	endloop1:
	
	
	# PHASE 3: PRINT THE RESULT
	# =============================================
	# Print the header
	li $v0, 4
	la $a0, msg11
	syscall
	li $v0, 4
	la $a0, msg7
	syscall
	li $v0, 4
	la $a0, msg8
	syscall

	
	
	la $t0, sortedOrder # get address of sorted order
	la $t2, studentList # get address of student list
	li $t1, 0
	
	loop3:
	beq $t1, $s0, endloop3
	nop
	
	# Load index of current student
	lw $t3, 0($t0)
	
	# calculate address of current student based on index
	li $t4, 32
	mult $t3, $t4
	mflo $t4 # 32 most significant bits of multiplication to $t4

	
	# pointer to current student
	add $t4, $t4, $t2
	
	
	# *** Print student's info
    li $v0, 4
	la $a0, msg9
	syscall
    
	lw $a0, 28($t4) #integer to be printed
	li $v0, 1 # print int - mark
	syscall
	
	li $v0, 4
	la $a0, msg9
	syscall
	
	li $v0, 4 # print string - name
	la $a0, 0($t4)
	syscall
	
	
	addi $t0, $t0, 4
	addi $t1, $t1, 1
	j loop3
	nop
	endloop3:
	

	# Exit the program
	j exit0

# Input number of student -> $s0
get_num_of_student:
	li $v0, 51
	la $a0, msg1
	syscall
	
	# If choose Cancel, exit the program
   	beq $a1, -2, exit0
   	nop
	# Check valid for mark
   	bne $a1, 0, error_on_get_num_of_student
   	nop
   	# Check < 0
   	slt $t0, $a0, $zero
   	bne $t0, 0, error_on_get_num_of_student
   	nop
   	# Check > 100
   	li $t2, 100
   	slt $t0, $t2, $a0
   	bne $t0, 0, error_on_get_num_of_student
   	nop
	
	addi $s0, $a0, 0
	
	jr $ra
	nop

error_on_get_num_of_student:
	li $v0, 55
	la $a0, msg10
	syscall
	j get_num_of_student
	nop

# Print list of student
# Using tmp variables:
# + $t8 as count variable
# + $t9 as student list pointer
print_student_list:

	# Print the header
	li $v0, 4
	la $a0, msg6
	syscall
	li $v0, 4
	la $a0, msg7
	syscall
	li $v0, 4
	la $a0, msg8
	syscall


	li $t8, 1
	la $t9, studentList

	loop_std_list:
    bgt $t8, $s0, end_loop_std_list
    
    # *** Print student's info
    li $v0, 4
	la $a0, msg9
	syscall
    
	lw $a0, 28($t9) #integer to be printed
	li $v0, 1 # print int - mark
	syscall
	
	li $v0, 4
	la $a0, msg9
	syscall
	
	li $v0, 4 # print string - name
	la $a0, 0($t9)
	syscall
	
    
    # Increase count variable
    addi $t8, $t8, 1
    
    # Increase student data pointer
    addi $t9, $t9, 32
    
    j loop_std_list
    nop
    
	end_loop_std_list:
	
	jr $ra
	nop
	

# Return error and exit the program
exit1:
	li $v0, 4
	la $a0, msge
	syscall

# Exit the program
exit0: