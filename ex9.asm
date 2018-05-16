#include <iregdef.h>

.data

xau: .asciiz "                                            ************* 

 **************                            *3333333333333*

 *111111111111111*                         *33333******** 

 *11111******111111*                       *33333*        

 *11111*      *11111*                      *33333******** 

 *11111*       *11111*      *************  *3333333333333*

 *11111*       *11111*    **22222*****222* *33333******** 

 *11111*       *11111*  **2222*        **  *33333*        

 *11111*      *111111*  *2222*             *33333******** 

 *11111*******111111*  *22222*             *3333333333333*

 *1111111111111111*    *22222*             ************** 

 ***************       *22222*                            

       ---              *2222**                           

     / o o \\             *2222****   *****                

     \\   > /              **222222***222*                 

      -----                 ***********    dce.hust.edu.vn

"

scan: .asciiz "nhap 1 de doi mau D,2 cho C va con lai cho E\n"

scan2: .asciiz "ban muon mau nao\n"

menu: .asciiz "nhap lua chon\n1:xoa mau\n2:doi vi tri\n3:doi mau\n"

.text

.set noreorder

.globl start

.ent start

start:

	la	a0,xau		#load the address of test string to a0

	nop

	jal printf

	nop

	add v0,zero,zero

	jal	promstrlen		#print test tring to console

	nop

	add s1,a0,zero		#sao luu dia chi goc trong s1

	add s2,v0,zero		#sao luu do dai trong s2

while:

	add v0,zero,zero

	la a0,menu

	nop

	jal printf

	nop

	add v0,zero,zero

	nop

	jal getchar

	nop

	li t0,'1'			#cac lua chon

	li t1,'2'

	li t2,'3'

	beq v0,t0,case1

	nop

	beq v0,t1,case2

	nop

	beq v0,t2,case3

	nop

	j Exit

	nop

case1:

	jal show

	nop

	j while

	nop

case2:

	jal swap

	nop

	j while

	nop

case3:

	jal color

	nop

	j while

	nop

Exit:

	j Exit

	nop

.end start

.ent show

show:

	add t0,zero,zero	#khoi tao i=0

	add t1,s1,zero		#khoi tao dia chi

	add t2,s2,zero 		#khoi tao ket thuc

	add s3,zero,ra

loop:

lb a0,0(t1)

nop

slti t3,a0,58			#kiem tra so <9

addi t4,zero,47			#kiem tra so >0

slt t5,t4,a0

and t6,t5,t3			#kiem tra so

beq t6,zero,draw

nop

li a0,' '

nop

draw:

jal putchar 

nop

addi t1,t1,1

addi t0,t0,1

slt t7,t0,t2

bne t7,zero,loop

nop

nop

add ra,zero,s3

j ra

.end show

.ent swap

swap:

	add t0,zero,zero	#khoi tao i=0

	add t1,s1,zero		#khoi tao dia chi

	addi t2,zero,16 	#khoi tao ket thuc

	add s3,zero,ra

loop1:

	addi t4,t1,42		#batn dau hien thi chu E

	addi t6,t1,58

loop2:

	lb a0,0(t4)

	nop

	jal putchar

	nop

	addi t4,t4,1

	slt t5,t4,t6

	bne t5,zero,loop2

	nop					#ket thuc vong lap hien thi E

	addi t4,t1,0		#bat dau vong lap hien thi 2 chu

	addi t6,t1,42

loop3:

	lb a0,0(t4)

	nop

	jal putchar

	nop

	addi t4,t4,1

	slt t5,t4,t6

	bne t5,zero,loop3

	nop

	li a0,'\n'		#hien thi xuong dong

	nop

	jal putchar

	nop

	addi t1,t1,59

	addi t0,t0,1

	slt t3,t0,t2

	bne t3,zero,loop1

	nop

	add ra,s3,zero

	jr ra

	nop

.end swap

.ent color

color:

	add s3,zero,ra

	addi a3,zero,57		#mau ?

	la a0,scan

	nop

	jal printf

	nop

	jal getchar

	nop

	li t1,'1'

	li t2,'2'

	beq v0,t1,D

	nop

	beq v0,t2,C

	nop

	j E

	nop

D:

	addi a1,zero,0

	addi a2,zero,22

	j continue

	nop

C:

	addi a1,zero,22

	addi a2,zero,42

	j continue

	nop

E:	

	addi a1,zero,42		#gioi han chu cai

	addi a2,zero,58		#gioi han chu cai

continue:

	la a0,scan2

	nop

	jal printf

	nop

	jal getchar

	nop

	add a3,zero,v0

	add t0,zero,zero	#khoi tao i=0

	add t1,s1,zero		#khoi tao dia chi

	addi t2,zero,16 	#khoi tao ket thuc

loop4:

	addi t4,t1,0	#batn dau hien thi theo cot

	addi t6,t1,58

	add t7,t4,a1	#ghi nho gioi han

	add t8,t4,a2	#ghi nho gioi han

	addi s7,zero,47	#kiem tra chu so

loop5:

	lb a0,0(t4)

	nop

	slt t9,t7,t4	#nam trong pham vi chu cai nao?

	slt t5,t4,t8

	and t5,t5,t9

	beq t5,zero,draw2

	slti t9,a0,58

	slt t5,s7,a0

	and t5,t5,t9

	beq t5,zero,draw2

	nop

	add a0,zero,a3

	nop

draw2:	

	jal putchar

	nop

	addi t4,t4,1

	slt t5,t4,t6

	bne t5,zero,loop5

	nop				#ket thuc vong lap trong

	li a0,'\n'		#hien thi xuong dong

	nop

	jal putchar

	nop

	addi t1,t1,59

	addi t0,t0,1

	slt t3,t0,t2

	bne t3,zero,loop4

	nop

	add ra,s3,zero

	jr ra

	nop	

.end color