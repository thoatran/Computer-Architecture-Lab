#include <iregdef.h>

.data

	DemKiTu:	.space	1024

	String:		.space	400

	CanLe:		.asciiz	"    "

	MoDau:		.asciiz	"PROJECT 4: DEM KI TU TRONG VAN BAN"

	NhapVB:		.asciiz "\nVan ban can soan thao:\n"

	DauCach:	.asciiz	"Space"

	TanSo:		.asciiz	" xuat hien: %d lan\n"

	TanSo1:		.asciiz	" : %5d/ %5d%c "

	TongSo:		.asciiz "Tong so ki tu: %d ki tu\n"

.text

.set reorder

.globl start

.ent start

start:

	la		a0,MoDau				#ghi ra cau mo dau

	jal		printf

	la		a0,NhapVB

	jal		printf

	

	//Nhap van ban can dem ki tu

	jal		NhapVanBan				#nhay den ham NhapVanBan

	

	//ghi ra ket qua

	jal		GhiKetQua				#nhay den ham GhiKetQua

	

	Exit:							#vong lap Exit

	j		Exit

.end start

/*--------------------------------------------------*/

.ent NhapVanBan

NhapVanBan:

	addi	sp,sp,-4				#luu gia tri thanh ghi can dung

	sw		ra,0(sp)

	

	la		s0,DemKiTu				#s0 luu mang dem so luong ki tu

	addi	s4,zero,0				#s4 luu so luong ki tu co trong van ban

	addi	t0,zero,-1				#bien chay t0 cua vong lap

	Fillchar:						#khoi tao mang s0 deu bang 0

		addi	t0,t0,1

		beq		t0,256,KT_Fillchar

		add		t1,zero,zero

		sll		t2,t0,2

		add		t2,t2,s0

		sw		t1,0(t2)

	KT_Fillchar:

	

	DocVanBan:						#doc van ban

		la		a0,String

		jal		gets

		addi	a0,a0,-1

		beq		a0,v0,KT_DocVanBan	#neu gap 2 dau Enter thi ket thuc buoc doc van ban

		add		a0,v0,zero

		jal		XuLyChuoi			#doc tung dong va xu li chuoi

		j		DocVanBan

	KT_DocVanBan:

	

	lw		ra,0(sp)

	addi	sp,sp,4

	jr		ra

.end NhapVanBan

/*--------------------------------------------------*/

.ent XuLyChuoi						#xet tung phan tu chuoi a0, tang mang s0 tuong ung

XuLyChuoi:

	add		t0,a0,zero

	XuLy:							#vong lap de xet toan bo a0

		lb		t1,0(t0)

		beq		t1,0,KT_XuLy

		addi	s4,s4,1				#tang bien dem so ki tu cua van ban

		sll		t1,t1,2

		add		t1,t1,s0			#

		lw		t2,0(t1)			#tang gia tri

		addi	t2,t2,1				#cua mang s0 tuong ung

		sw		t2,0(t1)			#

		addi	t0,t0,1

		j		XuLy

	KT_XuLy:

	jr		ra

.end XuLyChuoi

/*--------------------------------------------------*/

.ent GhiKetQua						#ghi ket qua ra man hinh xonsole

GhiKetQua:

	addi	sp,sp,-4

	sw		ra,0(sp)

	

	la		a0,TongSo				#ghi tong so ki tu trong van ban

	add		a1,s4,zero

	jal		printf

	addi	t0,zero,-1

	For:							#vong lap de thong ke tung ki tu da xuat hien trong van ban

		addi	t0,t0,1

		beq		t0,256,KT_For

		sll		t1,t0,2

		add		t1,t1,s0

		lw		t1,0(t1)

		beq		t1,0,For

		add		a0,t0,zero

		beq		a0,'\n',For			#bo qua dau xuong dong

		bne		a0,' ',xxx

		la		a0,DauCach			#neu la dau ' ' thi ghi ra la "Space"

		jal		printf

		j		yyy

		xxx:

		jal		putchar

		la		a0,CanLe

		jal		printf

		yyy:

		add		a0,zero,t1			#ghi ra tan so

		add		a1,s4,zero			#xuat hien cua

		jal		TiLe				#ki tu trong mang s0

		la		a0,TanSo1

		add		a1,zero,t1

		addi	a3,zero,'%'

		jal		printf

		add		a0,a2,zero

		jal		GhiDauSao

		j		For

	KT_For:

	lw		ra,0(sp)

	addi	sp,sp,4

	jr		ra

.end GhiKetQua

/*--------------------------------------------------*/

.ent GhiDauSao						#ghi ra dau sao, moi dau '*' tuong ung voi ti le 2%

GhiDauSao:

	addi	sp,sp,-12

	sw		ra,0(sp)

	sw		a1,4(sp)

	sw		t0,8(sp)

	

	srl		a1,a0,1					#a1=1/2 ti le a0 cua ki tu

	addi	a0,zero,'*'

	addi	t0,zero,1

	Ghi:							#vong lap de ghi ra a1 ki tu '*'

		bgt		t0,a1,KT_Ghi

		jal		putchar

		addi	t0,t0,1

		j		Ghi

	KT_Ghi:

	addi	a0,zero,'\n'

	jal		putchar

	

	lw		ra,0(sp)

	lw		a1,4(sp)

	lw		t0,8(sp)

	addi	sp,sp,12

	jr		ra

.end GhiDauSao

/*--------------------------------------------------*/

.ent TiLe								#dau vao a0, a1. ket qua la a2

TiLe:

	addi	sp,sp,-12

	sw		t0,0(sp)

	sw		t1,4(sp)

	sw		ra,8(sp)



	//t0=100*a0

	add		t0,zero,zero

	sll		t1,a0,6

	add		t0,t0,t1

	sll		t1,a0,5

	add		t0,t0,t1

	sll		t1,a0,2

	add		t0,t0,t1

	

	//chia t0 cho a1, luu gia tri vao a2

	add		a2,zero,zero

	Loop:

		blt		t0,a1,Done				#neu t0<a1 thi dung phep chia

		add		t1,a1,zero				#t1 dung de dich bit trai cua a1

		addi	t2,zero,1				#t2 de luu gia tri se dc tang o ket qua

		Tim:

			bgt		t1,t0,Done_Tim		#tim t1 lon nhat ko vuot qua t0

			sll		t1,t1,1

			sll		t2,t2,1

			j		Tim

		Done_Tim:

		srl		t1,t1,1

		srl		t2,t2,1

		sub		t0,t0,t1

		add		a2,a2,t2				#ket qua ghi vao a2

		j		Loop

	Done:

	lw		t0,0(sp)

	lw		t1,4(sp)

	lw		ra,8(sp)

	addi	sp,sp,12

	jr		ra

.end TiLe