#include <iregdef.h>

#include <idtcpu.h>

#include <excepthdr.h>

#define LEDS     0xbf900000

#define SWITCHES 0xbf900000

#define BUTTONS  0xbfa00000



#define PIO_SETUP2 0xffffea2a

        .data

        Led_val:          .byte 0x00		  //00000000

        Led_K1_press_val: .byte 0xf0	 	  //11110000

        Led_K2_press_val: .byte 0x3c		  //00111100

		isFirst:		  .word 0x0		   	  //TRUE

        .text

        # Interrupt routine. Uses ra, a0, a1, a2, and a3.

        # It is also necessary to save v0, v1 and t0-t9

        # since they may be used by the printf routine.

        .globl introutine

        .ent introutine

        .set noreorder

        .set noat

introutine:

		#--------------------------------------------------------

		# SAVE the current REG FILE to stack

		#--------------------------------------------------------

        subu    sp, sp, 22*4    # Allocate space, 18 regs, 4 args

        sw      AT, 4*4(sp)     # Save the regist6ers on the stack

        sw      v0, 5*4(sp)

        sw      v1, 6*4(sp)

        sw      a0, 7*4(sp)

        sw      a1, 8*4(sp)

        sw      a2, 9*4(sp)

        sw      a3, 10*4(sp)

        sw      t0, 11*4(sp)

        sw      t1, 12*4(sp)

        sw      t2, 13*4(sp)

        sw      t3, 14*4(sp)

        sw      t4, 15*4(sp)

        sw      t5, 16*4(sp)

        sw      t6, 17*4(sp)

        sw      t7, 18*4(sp)

        sw      t8, 19*4(sp)

        sw      t9, 20*4(sp)

        sw      ra, 21*4(sp)

        # Note that 1*4(sp), 2*4(sp), and 3*4(sp) are

        # reserved for printf arguments

        .set reorder

        mfc0    k0, C0_CAUSE   				     # Retrieve the cause register 

        mfc0    k1, C0_EPC     				     # Retrieve the EPC

        lui     s0, 0xbfa0      			     # Place interrupt I/O port address in s0



        move    a1, k0         					 # Put cause in a1

        move    a2, k1        					 # Put EPC in a2

        lbu     a3, 0x0(s0)    					 # Read the interrupt I/O port

        

        la      t0, LEDS						 # Place address of LEDs in t0

             				    

        la 		t1, Led_val					     // Place address of LEDs value in t1

        lb      a0, 0x0(t1)    					 // Read LEDs status and save to a0

             

		andi 	t2,a1,0xffff				     

		li	    t5,0x2000	

		bne	    t2,t5,Exit_Interrupt	         //Exit if first 2bytes of C0_cause not equal 0x2000 ( not K1,K2,Timer interrupt)

      

        andi 	t3,a3,0x02						 

        bne		t3,zero,External_K1_Interrupt    //Check interrupt I/O port is K1

        

        andi 	t3,a3,0x01						 

        bne		t3,zero,External_K2_Interrupt    //Check interrupt I/O port is K2

        

        j       External_Timer_Interrupt		 //else is interrupt timer

        

External_K1_Interrupt:  

		la		t4,Led_K1_press_val			     	

		lb		a0,0x0(t4)						 //Set a0 = Led_K1_press_val

		j       Exit_Interrupt

		

External_K2_Interrupt:  					     

		la		t4,Led_K2_press_val

		lb		a0,0x0(t4)    					 //Set a0 = Led_K2_press_val

     	j       Exit_Interrupt

     	

External_Timer_Interrupt:					

        la		s1,isFirst					  	 	

        lw		s2,0x0(s1) 					     //get flag isFirst Value

          

        bne		s2,zero,After_Times			     //Check the Times Timer_Interrupt

        

First_Time: 

		la		t5,SWITCHES						 //if first time Timer_Interrupt

		lb 		a0,0x0(t5)						 //save SWITCHES state to a0	

		

		li		t6,0x1							 	

		sw 		t6,0x0(s1)						 //change value of flag isFirstTime

		

		j		Exit_Interrupt



After_Times:     										 

        nor     a0, a0,zero						 //Set a0 = reverse a0 value	

		j       Exit_Interrupt

		

Exit_Interrupt:        

        sb      a0, 0x0(t0)    			         // Save a0 to LEDs    (I/O port)

		sb		a0,	0x0(t1)						 // Save a0 to LED_val (In RAM)

		

		sb      zero,0x0(s0)                     // Acknowledge interrupt, (resets latch)	

.set noreorder

        lw      ra, 21*4(sp)    # Restore the registers from the stack

        lw      t9, 20*4(sp)

        lw      t8, 18*4(sp)

        lw      t7, 18*4(sp)

        lw      t6, 17*4(sp)

        lw      t5, 16*4(sp)

        lw      t4, 15*4(sp)

        lw      t3, 14*4(sp)

        lw      t2, 13*4(sp)

        lw      t1, 12*4(sp)

        lw      t0, 11*4(sp)

        lw      a3, 10*4(sp)

        lw      a2, 9*4(sp)

        lw      a1, 8*4(sp)

        lw      a0, 7*4(sp)

        lw      v1, 6*4(sp)

        lw      v0, 5*4(sp)

        lw      AT, 4*4(sp)

        addu    sp, sp, 22*4    # Return activation record

        # noreorder must be used here to force the

        # rfe-instruction to the branch-delay slot

        jr      k1              # Jump to EPC

        rfe                     # Return from exception 

                                # Restores the status register

        .set reorder

        .end introutine



        # The only purpose of the stub routine below is to call

        # the real interrupt routine. It is used because it is 

        # of fixed size and easy to copy to the interrupt start

        # address location.

        .ent intstub

        .set noreorder

intstub: 

        j       introutine

        nop

        .set reorder

        .end intstub





        .globl start            # Start of the main program

        .ent start

start:  lh      a0, PIO_SETUP2  # Enable button port interrupts

        andi    a0, 0xbfff

        sh      a0, PIO_SETUP2

        lui     t0, 0xbfa0      # Place interrupt I/O port address in t0

        sb      zero,0x0(t0)    # Acknowledge interrupt, (resets latch)

        la      t0, intstub     # These instructions copy the stub

        la      t1, 0x80000080  # routine to address 0x80000080

        lw      t2, 0(t0)       # Read the first instruction in stub

        lw      t3, 4(t0)       # Read the second instruction

        sw      t2, 0(t1)       # Store the first instruction 

        sw      t3, 4(t1)       # Store the second instruction

        mfc0    v0, C0_SR       # Retrieve the status register

        li      v1, ~SR_BEV     # Set the BEV bit of the status

        and     v0, v0, v1      # register to 0 (first exception vector)

        ori     v0, v0, 1       # Enable user defined interrupts

        ori     v0, v0,EXT_INT3 # Enable interrupt 3 (K1, K2, timer)

        mtc0    v0, C0_SR       # Update the status register

Loop:   b       Loop            # Wait for interrupt

        .end start

