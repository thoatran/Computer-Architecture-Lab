        # Laboratory Exercise 12, Home Assignment 2

        # This is a simple program to illustrate the idea of

        # interrupts. The interrupt routine start address is

        # 0x80000080. Only a small stub routine that immediately

        # jumps to the real interrupt routine is stored at this

        # address. The stub routine is copied to this address

        # during the program initialization. 

#include <iregdef.h>

#include <idtcpu.h>

#include <excepthdr.h>

#define SWITCHES 0xbf900000

#define LEDS     0xbf900000

#define PIO_SETUP2 0xffffea2a

        .data

    message: .asciiz "THANK YOU!"

    string2: 	 .asciiz  ">        so phim da an:     %d                                <\n"

    ln: 	.asciiz "\n"

        

        		//---Menu------------------------------------------

	string1: .asciiz   	  "=============================================================\n"

	menu: 	 .asciiz      "=------------------- Program TypeSpeed----------------------=\n" 

	

        

        

        

        # Format string for the interrupt routine

Format: .asciiz "Cause = 0x%x, EPC = 0x%x, Interrupt I/O = 0x%x\n"





		



        .text

        # Interrupt routine. Uses ra, a0, a1, a2, and a3.

        # It is also necessary to save v0, v1 and t0-t9

        # since they may be used by the printf routine.

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# GENERAL INTERRUPT SERVED ROUTINE for all interrupts

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.globl introutine

.ent introutine

.set noreorder		

.set noat				# Not warning if the AT register is used       

introutine:

		#--------------------------------------------------------

		# SAVE the current REG FILE to stack

		#--------------------------------------------------------

        subu    sp, sp, 22*4    # Allocate space, 18 regs, 4 args

        sw      AT, 4*4(sp)     # Save the registers on the stack

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

       // sw      t5, 16*4(sp)

        sw      t6, 17*4(sp)

       // sw      t7, 18*4(sp)

        sw      t8, 19*4(sp)

        sw      t9, 20*4(sp)

        sw      ra, 21*4(sp)

        # Note that 1*4(sp), 2*4(sp), and 3*4(sp) are

        # reserved for printf arguments

        .set reorder

        #--------------------------------------------------------

        # Detect the CAUSE of Interrupt, maybe K1, K2, Timer and

        # the instruction address in the main program when it happens (to return later).

        #--------------------------------------------------------

        mfc0    k0, C0_CAUSE    # Retrieve the cause register 

        mfc0    k1, C0_EPC      # Retrieve the EPC

        

		#--------------------------------------------------------

        # Get the I/O port address

        # Used to detect K1, K2, timer were pressed

        #--------------------------------------------------------

        lui     s0, 0xbfa0      # Place interrupt I/O port address in s0

        

        #--------------------------------------------------------

        # The main function of GENERAL INTERRUPT SERVED ROUTINE

        # Print CAUSE, EPC, I/O Port to console

        #--------------------------------------------------------        

        la      a0, Format      # Put format string address in a0

        move    a1, k0          # Put cause in a1

        move    a2, k1          # Put EPC in a2

        lbu     a3, 0x0(s0)     # Read the interrupt I/O port

        #jal     printf          # Call printf

        nop

        //------in-----------------------------------------------

        beq t5, zero,Next

Printf: 

		la a0, string2

		add a1, zero, t5

	    jal printf 

	    nop

	    addi t5, zero,0

        //-------------------------------------------------------

Next:

		add		a0,zero,t7

		sub		t7,t7,t7		

        la      t0, LEDS        # Place address of LEDs in t0

        sb      a0, 0x0(t0)     # Output switch position to LEDs  

        

        #--------------------------------------------------------

        # Reset the I/O port address to zero after serving interrupt

        #--------------------------------------------------------

        sb      zero,0x0(s0)    # Acknowledge interrupt, (resets latch)

        

		#--------------------------------------------------------

		# RESTORE the REG FILE from STACK

		#--------------------------------------------------------        

        .set noreorder

        lw      ra, 21*4(sp)    # Restore the registers from the stack

        lw      t9, 20*4(sp)

        lw      t8, 18*4(sp)

        //lw      t7, 18*4(sp)

        lw      t6, 17*4(sp)

      //  lw      t5, 16*4(sp)

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

        

        #--------------------------------------------------------

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

start:



//	//-----In ra MENU---------------------

	

	la a0, string1

	jal printf

	nop

	

	la a0, menu

	jal printf		#in ra string menu

	nop



        #----------------------------------------------------------

        # Enable IO PIN of K1, K2 buttons

        #----------------------------------------------------------

	    lh      a0, PIO_SETUP2  # Enable button port interrupts

        andi    a0, 0xbfff

        sh      a0, PIO_SETUP2

        #----------------------------------------------------------

        # Reset I/O port address before enable interrupts

        #----------------------------------------------------------

        lui     t0, 0xbfa0      # Place interrupt I/O port address in t0, t0 = 0xbfa0.0000

        sb      zero,0x0(t0)    # Acknowledge interrupt, (resets latch)

                

        #----------------------------------------------------------

        # Register the GENERAL INTERRUPT SERVED ROUTINE

        #----------------------------------------------------------

        la      t0, intstub     # These instructions copy the stub

        la      t1, 0x80000080  # routine to address 0x80000080

        lw      t2, 0(t0)       # Read the first instruction in stub

        lw      t3, 4(t0)       # Read the second instruction

        sw      t2, 0(t1)       # Store the first instruction 

        sw      t3, 4(t1)       # Store the second instruction

        

        #----------------------------------------------------------

        # Set the status register to ENABLE EXPECTED INTERRUPTS 

        # such as K1, K2, timer and ENABLE THE GENERAL INTERRUPT

        #----------------------------------------------------------

        mfc0    v0, C0_SR       # Retrieve the status register				,v0 = status_register

        li      v1, ~SR_BEV     # Set the BEV bit of the status				,SR_BEV = 0x00400000	/* use boot exception vectors */

        and     v0, v0, v1      # register to 0 (first exception vector)	,v0 = status_register and (not SR_BEV)

        ori     v0, v0, 1       # Enable user defined interrupts			,v0 = status_register and (not SR_BEV) or SR_IEC, /* SR_IEC= cur interrupt enable, 1 => enable */

        ori     v0, v0,EXT_INT3 # Enable interrupt 3 (K1, K2, timer)		,v0 = status_register and (not SR_BEV) or SR_IEC or EXT_INT3         

        mtc0    v0, C0_SR       # Update the status register        		,status_register = status_register and (not SR_BEV) or SR_IEC or EXT_INT3

        #----------------------------------------------------------

        # No-end loop, main program, to demo the effective of interrupt

        #----------------------------------------------------------

Loop:

		jal getchar

	    nop

	    sll 	t7,t7,1

	    addi 	t7,t7,1

	    addi 	t5, t5,1

	    

		nop

		nop

		nop

		nop

		nop

        b Loop            # Wait for interrupt







.end start