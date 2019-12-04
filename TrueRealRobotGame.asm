########################################################################
# Program: RobotGame       			        Programmer: Osman Halwani
# Due Date: Nov 14, 2019					Course: CS2640
########################################################################
# Overall Program Functional Description:
#	This is a robot game. The player moves around trying to avoid robots. These robots
#   move towards the player each turn. The player must avoid walls and the robots.
#   If the robots hit the wall they will disappear 
#
########################################################################
# Register usage in Main:
#   $v0, $a0 -- for subroutine linkage and general calculations
#	
########################################################################
# Pseudocode Description:
#	1. Asks for seed
#	2. Get a value from the user, use it to seed the random number generator
#	3. asks player for move
#	4. Loop:
#		a. Asks player for move 
#		b. robots move to player 
#	4. If player lost say they lost, if they win say they win 
#	5. Clean up, print a 'bye' message, and leave.
#
########################################################################
  #todo add rubble for draw object
  .data

wid:       .word 39 # Length of one row, must be 4n-1
hgt:	   .word 30 # Number of rows 
linelen:   .word 40 # wid + 1
boardlen:  .word 1200 ## linelen * hgt
numwalls:  .word 50
zeroVar:   .word 0
board:     .space 1204 # Extra space for the 0, yet still be aligned 
enterSeed: .asciiz "\n Enter a seed number "
choose:    .asciiz "\n Enter a u for up , d for down , l for left , r for right p for pause , j for jump to random location q to quit : " 
newline:   .asciiz "\n\n"
loser:     .asciiz " \nhaha your a loser you lost\n "
winner:     .asciiz " \nhaha your a winner \n "
NeedOrGetError:   .word 1, 2, 3, 4
objects:  .space 800
buffer:   .space 4     # To hold player's move
numrobot: .word 20 
numalive: .word 20
.globl main
.text



main: 
		
		li        $v0 , 4 # Call the IO service to print string
		la		  $a0 , enterSeed
		syscall
		li		  $v0, 5			# Call the Read Integer I/O Service to
		syscall					    #   get seed value		
		add		  $a0, $v0, $0      # storing seed in $a0
		jal       seedrand
		j         initBoard
backFromInitBoard:        
		j         addWalls      # add walls function call
		
startPlace:	
		                # coming back from walls function
		addi $a1 , $0 , 1  # need 1 to declare object as person
		la   $a2 , objects  # address of object    
		jal  placeObj  # calling placeObj
		
		la    $a0 , objects   # loading address of objects 
		jal   drawobj        # calling drawobj
		lw $t5 , numrobot # loop for robots 
		la $a2 , objects # loading objects 
robotLoop : 
	    
	    addi $a2 , $a2 , 16 # want to start at  robots and increasing to go to next Robot
	    addi $a1 , $0 , 2  # need 2 to declare object as robot
	    jal placeObj
	    add $a0 , $a2 , $0 # need to do this because drawobj needs $a0 to hold address
	    jal drawobj
	    sub $t5 , $t5 , 1 # going down
	    ble $t5 , $0 , mainLoop  # break loop if $t5 = 0 
	    j robotLoop
	    
	    
	    
	    
	    
		
mainLoop:
		
	
	
		li        $v0 , 4 # Call the IO service to print string
		la		  $a0 , newline
		syscall
		li        $v0 , 4   # Call the IO service to print a string
		la        $t5,board
		la        $a0, 0($t5)
		syscall
		li        $v0 , 4 # Call the IO service to print string
		la		  $a0 , choose # print prompt message 
		syscall
		li		  $v0, 12			# Call the Read String I/O Service to
		syscall
		la        $a0 , buffer  # loading address of buffer
		
		sb        $v0 , 0($a0)   # storing choice into buffer
		lb        $s1 , 0($a0)   # holding entered move such up or down etc.
		
		addi $t0 , $0 , 117 #  code for u		
		addi $t1 , $0 , 100 #  code for d		
		addi $t2 , $0 , 108 #  code for l		
        addi $t3 , $0 , 114 #  code for r		
		addi $t4 , $0 , 106 #  code for j		
	    addi $t5 , $0 , 113 # code for q		
		addi $t6 , $0 , 112 # code for p
		
		la   $a0 , objects # loading address of object

		beq  $s1 , $t0 ,  movenB  # if move north is true branch
		beq  $s1 , $t1 ,  movesB  # if move south is true branch
		beq  $s1 , $t2 ,  movewB  # if move left is true branch
		beq  $s1 , $t3 ,  moveeB  # if move right is true branch
		beq  $s1 , $t4 ,  movejB  # if move jump is true branch
		#beq  $s1 , $t5 ,  movenB  # if move q is true branch
		#beq  $s1 , $t6 ,  movenB  # if move p is true branch
		beq  $s1 , $t6 ,  leave  # if move p is true branch
		j moveBots
		
		la   $a0 , objects
		
		jal  drawobj
		
		
		j mainLoop	
			
		
	
		
		
	movenB:
		jal eraseobj # erasing object from current location
		la   $a0 , objects
		jal moven    # move object up
	    la   $a0 , objects  # load address
	    jal whatthere  # see whats on the new spot
	    addi $t0 , $0 , 46  # code for "." 
	    bne $v0 , $t0 , leave  # if player lands on # end program 
		jal  drawobj # draw object
		
        j moveBots	


	movesB:
		jal eraseobj # erasing object from current location
		la   $a0 , objects
		jal moves    # move object up
	    la   $a0 , objects  # load address
	    jal whatthere  # see whats on the new spot
	    addi $t0 , $0 , 46  # code for "." 
	    bne $v0 , $t0 , leave  # if player lands on # end program 
		jal  drawobj # draw object
         j moveBots		

		
	movewB:
		
		jal eraseobj # erasing object from current location
		la   $a0 , objects
		jal movew    # move object up
	    la   $a0 , objects  # load address
	    jal whatthere  # see whats on the new spot
	    addi $t0 , $0 , 46  # code for "." 
	    bne $v0 , $t0 , leave  # if player lands on # end program 
		jal  drawobj # draw object
        j moveBots	
		
	moveeB:
		jal eraseobj # erasing object from current location
		la   $a0 , objects
		jal movee    # move object up
	    la   $a0 , objects  # load address
	    jal whatthere  # see whats on the new spot
	    addi $t0 , $0 , 46  # code for "." 
	    bne $v0 , $t0 , leave  # if player lands on # end program 
		jal  drawobj # draw object
         j moveBots		
        
    movejB:
        jal eraseobj # erasing object from current location
		la   $a0 , objects
		jal movej    # move object up
	    la   $a0 , objects  # load address
	    jal whatthere  # see whats on the new spot
	    addi $t0 , $0 , 46  # code for "." 
	    bne $v0 , $t0 , leave  # if player lands on # end program 
		jal  drawobj # draw object
        j moveBots	
		
		
	moveBots:
		
		#lw $t7 , numalive
		#addi $t7 , $0 , 16
	loopBot:
	
		# for some reaon my loop keeps not working so i brute forced it 	
		la $a0 , objects
	 	add $a0 , $a0 ,16 # doing in order to pass robots in
		jal moveRobot
		# incrementing by 16 to access each object 
		la $a0 , objects 
		addi $a0 , $a0 , 32
		jal moveRobot 
		
		la $a0 , objects 
		addi $a0 , $a0 , 48
		jal moveRobot 
		
		la $a0 , objects 
		addi $a0 , $a0 , 64
		jal moveRobot 
		
		la $a0 , objects 
		addi $a0 , $a0 , 80
		jal moveRobot 
		
		la $a0 , objects 
		addi $a0 , $a0 , 96
		jal moveRobot 
		
		
		la $a0 , objects 
		addi $a0 , $a0 , 112
		jal moveRobot
		
		la $a0 , objects 
		addi $a0 , $a0 , 128
		jal moveRobot
		
		la $a0 , objects 
		addi $a0 , $a0 , 144
		jal moveRobot
		
		la $a0 , objects 
		addi $a0 , $a0 , 160
		jal moveRobot
		
		la $a0 , objects 
		addi $a0 , $a0 , 176
		jal moveRobot
		
		la $a0 , objects 
		addi $a0 , $a0 , 192
		jal moveRobot
		
		la $a0 , objects 
		addi $a0 , $a0 , 208
		jal moveRobot
		
		la $a0 , objects 
		addi $a0 , $a0 , 224
		jal moveRobot
		
		la $a0 , objects 
		addi $a0 , $a0 , 240
		jal moveRobot
		
		la $a0 , objects 
		addi $a0 , $a0 , 256
		jal moveRobot
		
		la $a0 , objects 
		addi $a0 , $a0 , 272
		jal moveRobot
		
		la $a0 , objects 
		addi $a0 , $a0 , 288
		jal moveRobot
		
		la $a0 , objects 
		addi $a0 , $a0 , 304
		jal moveRobot
		
		la $a0 , objects 
		addi $a0 , $a0 , 320
		jal moveRobot
		
		
		
		#sub $t5 , $t5 , 1 # going down
		#ble $t5 , $0 , mainLoop  # break loop if $t5 = 0
		move $a0 , $v1 
		
		
		
		j   checkBoardForP
		
		
		
		
			
leave:	   
            la $a0 , objects
            addi $t0 , $0 , 3
            sw   $t0, 12($a0)
            jal drawobj
            li        $v0 , 4 # Call the IO service to print string
			la		  $a0 , newline
			syscall
			li        $v0 , 4   # Call the IO service to print a string
			la        $t5,board
			la        $a0, 0($t5)
			syscall
			
			
		    li        $v0 , 4 # Call the IO service to print string
			la		  $a0 , loser
			syscall
			li        $v0, 10        # terminate program run and
   		    syscall            



checkBoardForP : 
	
			la $a0 , board # loading address of board 
			addi $t0 , $0 , 82 # used to hold R
			addi $t1 , $0, 80 # used to hold P
			addi $t2 , $0 , 1200 # used as counter 
keepLoop:  #slowest algorithm in history checking each coordinate to see if we win or lose
		   
		   addi $a0 , $a0 , 1 # moving pointer on board
		   lb $v0 , 0($a0)  # loading byte
		   beq $v0 , $t1 , mainLoop #if b is present go to main loop
		   addi $t2 , $t2 , -1 # drop counter by 1 
		   beq  $t2 , $0 , leave # if no P on board you lose 
		   beq  $t0 ,$0 , win  # you win if no R 
		   j keepLoop

win:
			 la $a0 , objects
            addi $t0 , $0 , 3
            sw   $t0, 12($a0)
            jal drawobj
            li        $v0 , 4 # Call the IO service to print string
			la		  $a0 , newline
			syscall
			li        $v0 , 4   # Call the IO service to print a string
			la        $t5,board
			la        $a0, 0($t5)
			syscall
			
			
		    li        $v0 , 4 # Call the IO service to print string
			la		  $a0 , winner
			syscall
			li        $v0, 10        # terminate program run and
   		    syscall       	


########################################################################
# Function Name: initBoard
########################################################################
# Functional Description:
# This is a leaf function, so we don't need to save the $ra register 
#
########################################################################
# Register Usage in the Function:
# -- Since this calls subroutines, we save $ra on the stack, then
# -- restore it. We also save $s0 and $s1 on the stack.
#
# $ t7,t8 -- loop cointers for the different loops 
# $t0 -- Pointer into the board
# $t1 -- Value we are going to place on the board 
# note we will be using t registers for holding the values of the char
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Set $t0 to point to the board
# 2. Draw the top row of the board:
#     a. looping wid times, place # t on the board
#	  b. Place new line on the board
# 3.  Draw middle of the board loop hgt - 2 times:
#     a. Place '#" on the board
#	  b. Looping wid - 2 times, place . on the board.
#	  C. place # on the board
#	  d. Place new line on the board
#   4. Draw buttom row of the board:
#      a. looping wid times, place # t on the board
#	  b. Place new line on the board
#  5. End the string by placing 0 on the board 
# 
#
########################################################################




initBoard: 
	lw    $t7 , wid    # storing wid word into $t7 for counting 
	
	la    $t0 , board   # loading address of board in $t0
	
	addi  $t3 , $0, 35  # storing 35 into $ t3 which is the # char code
	addi  $t4 ,$0 , 46  # storing "." into $t4 char code
	addi   $t5 , $0 , 13 # storing "\n" into $t5 char code
	jal    loopW
	



		
		
loopW: 
		
			sb    $t3 , 0($t0)  # store # byte
			addi  $t0 , $t0 , 1   # incrementing address pointer
			sub   $t7 , $t7 , 1  # decreasing loop counter
			ble   $t7 , $0 , newLine  # break loop if $t7 = 0 and add new line
			j     loopW
			
			
newLine:
			sb    $t5 ,0($t0)  # storing new line into board
			addi  $t0, $t0 ,1  # incrementing address pointer
			j     setMidLoop     # going to store middle of board now 
		
	
setMidLoop:   
           	lw   $t7 ,hgt   # loading word into $t7 for loop counter
           	sub  $t7, $t7 , 2    # subtract my two to loop hgt - 2 times	
           	lw   $t8 , wid      # loading word into $t8 for loop counter
           	sub  $t8, $t8 ,2     # subtract my two to loop wid - 2 times	
           	j    midLoop   
	       
	       
midLoop:  
			sb    $t3 ,0($t0)     # storing # into board 
			addi  $t0 , $t0 , 1   # incrementing address pointer
			
			jal  midLoopW     # jump to another inter loop 
come:
			sb    $t3 ,0($t0)  # storing # into board 
			addi  $t0 , $t0 , 1   # incrementing address pointer
			sb    $t5 ,0($t0)   # storing new line into board
			addi  $t0, $t0 ,1   # incrementing address pointer
			sub   $t7 , $t7 , 1  # decreasing loop counter for hgt
			# Resetting counter for midLoopW
			lw   $t8 , wid      # loading word into $t8 for loop counter
           	sub  $t8, $t8 ,2     # subtract my two to loop wid - 2 times
           	ble  $t7 , $0, bottom  # go to draw bottom row if $t7 is 0
			j     midLoop
			
			
			
			
midLoopW: 
		   sb    $t4 ,0($t0)  # storing "." into board 
		   addi  $t0 , $t0 , 1   # incrementing address pointer
		   sub   $t8 , $t8 , 1   # decreasing loop counter 
		   ble   $t8  , $0, come  # if counter is 0 go back to main loop
		   j     midLoopW			   # else keep looping
		   
		  
			
bottom:
			lw    $t7 , wid    # storing wid word into $t7 for counting 
loopHere:	sb    $t3 , 0($t0)  # store # byte
			addi  $t0 , $t0 , 1   # incrementing address pointer
			sub   $t7 , $t7 , 1  # decreasing loop counter
			ble   $t7 , $0 , newLine2  # break loop if $t7 = 0 and add new line
			j     loopHere   # loop 


newLine2:
			sb    $t5 ,0($t0)  # storing new line into board
			addi  $t0, $t0 ,1  # incrementing address pointer
			sw    $0 ,0($t0)  # storing 0 into board
			j     backFromInitBoard  

	
########################################################################
# Function Name: addWalls
########################################################################
# Functional Description:
# This routine adds extra walls in the middle of the board. The global
# numWalls indicates how many to add. Since we randomly place these,
# it is possible we will place some at the same spot, so there might
# be somewhat fewer than numWalls.
#
########################################################################
# Register Usage in the Function:
# -- Since this calls subroutines, we save $ra on the stack, then
# -- restore it. We also save $s0 and $s1 on the stack.
# $a0, $v0 -- Subroutine parameter and return passing.
# $s0 -- Loop counter: how many walls still to place
# $s1 -- The x-coordinate of the wall
# $t0 -- Pointer where to store the wall in the board
# $t1 -- general calculations.
# $s3 -- hold linelen value
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save the return address and S registers on the stack
# 2. Loop based on the number of walls to place:
# 2a. Get a random X coordinate (into $s1) and random Y coordinate.
# 2b. Compute Y * linelen + X
# 2c. Compute the final pointer by adding the 2b value to the address
# of the board.
# 2d. Store a wall character at that pointer.
# 5. Restore the return address and S registers
#
########################################################################


addWalls:

addi    $s0 , $0 , 50   # made the counter for walls remaining 46   

loopForWalls:
		jal    randX  # getting randX


        move     $s1 , $v0   # got x coor. into $s1
        jal		randY         # gettting randy
		
		


		move     $s2,  $v0    # got y coor into $s2
		lw       $s3 , linelen
		mult     $s3 , $s2    # multiply linelen and Y coord
        mflo     $s3         # storing answer in $s3
        add      $s3 , $s1 , $s3   # adding (Y*linelen)+ X
        la       $t0 , board   # loading address of board in $t0
        add      $t0 , $t0 , $s3   # adding $s3 to pointer of board to get new value 
		sb       $t3 ,0($t0)  # storing # into board 
		sub      $s0 , $s0 , 1 # decrementing loop counter
		ble      $s0  , $0,  startPlace  # go back to main
		
		 
        j        loopForWalls    # if counter is not 0 go back to  loopForWalls





########################################################################
# Function Name: int randX
########################################################################
# Functional Description:
# This routine gets a random number for the X coordinate, so the value
# will be between 1 and wid - 1.
#
########################################################################
# Register Usage in the Function:
# -- Since this calls rand, we save $ra on the stack, then restore it.
# $a0 -- the value wid - 2 passed to rand
# $v0 -- the return value from rand
# $t8 -- holds return address 
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save the return address on the stack
# 2. Get the value wid - 2
# 3. Pass this to rand, so we get a number between 0 and wid - 2
# 4. Add 1 to the result, so the number is between 1 and wid - 1
# 5. Restore the return address
#
########################################################################

randX: 

		lw     $a0 , wid  # loading wid into $a0
		
		sub   $a0 , $a0 , 2 # getting wid-2 value 
		
		
		add  $t8  , $ra , $0  # saving return
		
		jal   rand     # calling rand to get number
		
		addi  $v0, $v0 , 1 # adding one to number 
		
		jr   $t8
		













########################################################################
# Function Name: int randY
########################################################################
# Functional Description:
# This routine gets a random number for the Y coordinate, so the value
# will be between 1 and hgt - 1.
#
########################################################################
# Register Usage in the Function:
# -- Since this calls rand, we save $ra on the stack, then restore it.
# $a0 -- the value hgt - 2 passed to rand
# $v0 -- the return value from rand
# $t8 -- holds address 
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save the return address on the stack
# 2. Get the value hgt - 2
# 3. Pass this to rand, so we get a number between 0 and hgt - 2
# 4. Add 1 to the result, so the number is between 1 and hgt - 1
# 5. Restore the return address
#
########################################################################
	
	randY:
		lw     $a0 , hgt  # loading wid into $a0
		
		sub   $a0 , $a0 , 2 # getting wid-2 value 
		
		add  $t8  , $ra , $0  # saving return
		
		jal   rand     # calling rand to get number
		
		addi  $v0, $v0 , 1 # adding one to number 
		
		jr   $t8
	
	
	

########################################################################
# Function Name: int rand()
########################################################################
# Functional Description:
# This routine generates a pseudorandom number using the xorsum
# algorithm. It depends on a non-zero value being in the 'seed'
# location, which can be set by a prior call to seedrand. For this
# version, pass in a number N in $a0. The return value will be a
# number between 0 and N-1.
#
########################################################################
# Register Usage in the Function:
# $t0 -- a temporary register used in the calculations
# $v0 -- the register used to hold the return value
# $a0 -- the input value, N
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Fetch the current seed value into $v0
# 2. Perform these calculations:
# $v0 ^= $v0 << 13
# $v0 ^= $v0 >> 17
# $v0 ^= $v0 << 5
# 3. Save the resulting value back into the seed.
# 4. Mask the number, then get the modulus (remainder) dividing by $a0.
#
########################################################################
 .data
seed: .word 31415 # An initial value, in case seedrand wasn't called
 .text
rand:
 lw $v0, seed # Fetch the seed value
 sll $t0, $v0, 13 # Compute $v0 ^= $v0 << 13
 xor $v0, $v0, $t0
 srl $t0, $v0, 17 # Compute $v0 ^= $v0 >> 17
 xor $v0, $v0, $t0
 sll $t0, $v0, 5 # Compute $v0 ^= $v0 << 5
 xor $v0, $v0, $t0
 sw $v0, seed # Save result as next seed
 andi $v0, $v0, 0xFFFF # Mask the number (so we know its positive)
 div $v0, $a0 # divide by N. The reminder will be
 mfhi $v0 # in the special register, HI. Move to $v0.
 jr $ra # Return 
 
 
########################################################################
# Function Name: seedrand(int)
########################################################################
# Functional Description:
# This routine sets the seed for the random number generator. The
# seed is the number passed into the routine.
#
########################################################################
# Register Usage in the Function:
# $a0 -- the seed value being passed to the routine
#
########################################################################
seedrand:
 sw $a0, seed
 jr $ra
 
 
 
 
 ########################################################################
# Function Name: placeobj(idx, type)
########################################################################
# Functional Description:
# The $a2 register is the index of an object. $a1 is the type for
# this object. Create a new object, then find a place for it on the
# board.
#
########################################################################
# Register Usage in the Function:
# $a2 -- Index of object in question
# $a2 -- pointer to the object's structure.
# $t0, $t1,$s3,$t2 -- general calculations.
# $v0 -- subroutine linkage
# $a1 -- type of object
# #a3 - store return address
# $a0 - holds address of board 
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save space on the stack for the return address and $s0
# 2. Set $s0 to the pointer to this object
# 3. Store the type of the object
# 4. Compute a random X and random Y for the object, storing these.
# 5. Compute the pointer to this location on the board.
# 6. See if the location is empty ('.'). If not, loop back to 4.
#
########################################################################


placeObj:
    
    move  $a3  , $ra  # saving return address 
    
   
	addi  $a2 , $a2 , 12   # adding 12 to pointer to store type of object
	sw   $a1 , 0($a2)    # storing type of object
	addi  $a2 , $a2 , -12   # adding -12 to pointer to restore back
	
loopME:
	jal randX   # getting x coordinate
	move $t2 ,$v0  # moving x coordinate into $a0
	
	
				
		
	
	
	jal randY  # getting y coordinate
	
	move $t1 , $v0  #y coordinate in $t1
	   
	addi  $a2 , $a2 , 4   # adding 4 to pointer to store x coor	
	sw  $t2 , 0($a2)   # storing x in structure
	addi  $a2 , $a2 , 4   # adding 4 to pointer to store y coor	
    sw  $t1 , 0($a2)   # storing y in structure
	addi  $a2 , $a2 , -8   # adding -8 to pointer to restore back
	# computing pointer to location of x and y 
	lw       $s3 , linelen
	mult     $t1 , $s3    # multiply linelen and Y coord
    mflo     $s3         # storing answer in $s3
    add      $s3 , $t2 , $s3   # adding (Y*linelen)+ X
    sw       $s3 , 0($a2)     # storing pointer to location in board of object
   
    la       $a0 , board   # loading address of board 
    add      $a0 , $a0 , $s3       #  moving board board pointer to location of object  
	lb       $s7 , 0($a0)         # loading location to see whats inside 
	addi     $t4 ,$0 , 46  # storing "." into $t4 char code
	bne      $s7 , $t4 , loopME    # if location is not a "." then jump back to loop
	
	jr   $a3  


########################################################################
# Function Name: drawobj(idx)
########################################################################
# Functional Description:
# The $a0 register is the index of an object. Draw the object's character
# at that point on the board.
#
########################################################################
# Register Usage in the Function:
# $a0 -- Index of object in question
# $t0, $t1, $t2, $t3,$t4,$s1 -- general calculations.
# $s5 holds letter P

########################################################################
# Algorithmic Description in Pseudocode:
# 1. Compute the effective address of the object
# 2. Determine the character for this type of object
# 3. Place that character in the board at the object's location.
#
########################################################################
	
drawobj:
	addi $s5 , $0 ,80  # holds code for letter P 
	la  $t0 , board  #loading address of board
	addi $s6 ,$0 , 82  # holds code for letter R
	addi $s4 , $0 ,42 # holds code for * which is rubble 
	
	addi  $a0 ,$a0 , 12  # looking at what type of object this is 
	lw    $t4 ,0($a0)
	
	addi  $t1 ,$0,   1     # need a 1 constant to compare if player
	
	addi  $t2 , $0 , 2 # need a 2 constant to compare  if robot 
	
	addi  $s1 , $0 , 3 # need a 3 constant to compare if rubble
	
	beq   $t1 , $t4 , isPerson    # if object is a person branch
	
	beq   $s1 , $t4 , rubble     #  if rubble go to rubble
	
	
    addi $a0 , $a0 , -12 # restoring pointer to address on board
	lw   $t3 , 0($a0)   # loading address on board for object to be placed
	add  $t0 , $t3 , $t0 # moving board pointer to location of object
	sb   $s6 , 0($t0)   # store R in board for robot
	jr $ra








isPerson: 
		addi $a0 , $a0 , -12 # restoring pointer to address on board
		lw   $t3 , 0($a0)   # loading address on board for object to be placed
		add  $t0 , $t3 , $t0 # moving board pointer to location of object
		sb   $s5 , 0($t0)   # store P in board for player 
		jr $ra
		 

rubble:
	    addi $a0 , $a0 , -12 # restoring pointer to address on board
		lw   $t3 , 0($a0)   # loading address on board for object to be placed
		add  $t0 , $t3 , $t0 # moving board pointer to location of object
		sb   $s4 , 0($t0)   # store * in board for player 
		 


jr $ra 




########################################################################
# Function Name: eraseobj(idx)
########################################################################
# Functional Description:
# The $a0 register is the index of an object. Find the location of
# that object on the board, then store floor ('.') at that spot.
#
########################################################################
# Register Usage in the Function:
# $a0 -- Index of object in question
# $t0, $t1, $t2 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Compute the effective address of the object
# 2. Store a '.' at that point of the board
#
########################################################################

eraseobj:
	addi  $t2 ,$0 , 46  # storing "." into $t2 char code
	
	la $t0 , board # loading address of board
	
	lw $t1 , 0($a0) # loading address of of object on board
	
	add  $t0 , $t0 ,$t1  # getting location to remove object 
	
	sb   $t2 , 0($t0)  # storing "." in location
	
	
 jr $ra 
	
	
	
########################################################################
# Function Name: char whatthere(idx)
########################################################################
# Functional Description:
# The $a0 register is the index of an object. Find the location of
# that object on the board, then return the character at that location
# on the map.
#
########################################################################
# Register Usage in the Function:
# $a0 -- Index of object in question
# $t0, $t1 -- general calculations.
# $v0 -- return value
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Compute the effective address of the object
# 2. Fetch the value at that point of the board.
#
########################################################################

whatthere:
    
	la $t0 , board # loading address of board
    lw $t1 , 0($a0) # loading address of of object on board
    
    add  $t0 , $t0 ,$t1  # getting location of object
    
    lb   $v0 , 0($t0)  # returns character at location as a asciiz code 



jr $ra 
     

########################################################################
# Function Name: moven(idx)
########################################################################
# Functional Description:
# This routine moves one object north on the board (up the page).
# The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
# $a0 -- Index of object to move
# $t0, $t1 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Compute the effective address of the object
# 2. Decrement the Y value
# 3. Decrement the pointer by the line length
#
########################################################################

moven:

	
	
    
    lw $t1 , 8($a0) # loading y coordinate 
    
    addi $t1 , $t1 , -1   #decrementing y because we moved up
    
    sw   $t1, 8($a0)   # storing new Y value 
    
    lw   $t1 , 0($a0) # storing pointer address
    lw   $t0 , linelen   # loading linelen
    sub  $t1 , $t1 , $t0 # decrementing pointer by linelen
    
    sw   $t1, 0($a0)   # object now holds where it should go 
    
jr $ra   
    
    



########################################################################
# Function Name: moves(idx)
########################################################################
# Functional Description:
# This routine moves one object south on the board (down the page).
# The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
# $a0 -- Index of object to move
# $t0, $t1 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Compute the effective address of the object
# 2. Increment the Y value
# 3. Increment the pointer by the line length
#
########################################################################

moves:
	lw $t1 , 8($a0) # loading y coordinate 
    
    addi $t1 , $t1 , 1   #incrementing y because we moved up
    
    sw   $t1, 8($a0)   # storing new Y value 
    
    lw   $t1 , 0($a0) #   loading pointer address
    lw   $t0 , linelen   # loading linelen
    add  $t1 , $t1 , $t0 # increment pointer by linelen
    
    sw   $t1, 0($a0)   # object now holds where it should go 
    
jr $ra   
    

########################################################################
# Function Name: movew(idx)
########################################################################
# Functional Description:
# This routine moves one object west on the board (to the left).
# The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
# $a0 -- Index of object to move
# $t0, $t1 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Compute the effective address of the object
# 2. Decrement the X value
# 3. Decrement the pointer
#
########################################################################

movew:
    lw   $t1 , 4($a0) # loading x coordinate 
    
    addi $t1 , $t1 , -1   #decrementing x because we moved up
    
    sw   $t1, 4($a0)   # storing new x value 
    
    lw   $t1 , 0($a0)  # loading pointer address
   
   
    addi $t1 , $t1 , -1 # decrementing pointer 
    
    sw   $t1, 0($a0)   # object now holds where it should go 
    
  jr $ra  
    
########################################################################
# Function Name: movee(idx)
########################################################################
# Functional Description:
# This routine moves one object east on the board (to the right).
# The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
# $a0 -- Index of object to move
# $t0, $t1 -- general calculations.
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Compute the effective address of the object
# 2. Increment the X value
# 3. Increment the pointer
#
########################################################################   
    
movee: 
    

    lw   $t1 , 4($a0) # loading x coordinate 
    
    addi $t1 , $t1 , 1   #incrementing x because we moved up
    
    sw   $t1, 4($a0)   # storing new x value 
    
    lw   $t1 , 0($a0)  # loading pointer address
   
   
    addi $t1 , $t1 , 1 # incrementing pointer 
    
    sw   $t1, 0($a0)   # object now holds where it should go 
    
 jr $ra 
 
 
 
########################################################################
# Function Name: movej(idx)
########################################################################
# Functional Description:
# This routine moves one object to a random spot on the board.
# The $a0 register is the index of the object to move.
#
########################################################################
# Register Usage in the Function:
# We save the $ra and $s0 registers on the stack
# $a0 -- Index of object to move
# $s0 -- pointer to the object
# $t0, $t1,$t2 -- general calculations.
# $v0 -- subroutine linkage
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save $ra and $s0 on the stack
# 2. Set $s0 to be the pointer to the object
# 3. Get new random X and Y coordinates for the object
# 4. Compute the object's new board pointer
# 5. Restore $ra and $s0
#
########################################################################   
    
movej:

	move   $s0 , $a0 # holds pointer to object
	
	sw   $s0 , -4($sp)  # saving $s0 in stack
	
	sw   $ra , -8($sp)  # saving $return address to stack
    
    sub  $sp, $sp, 8  # moving stack pointer to hold return address
    
    jal randX    # getting randX
    
    lw  $s0 , 4($sp) # loading pointer
    
    move $a0,$s0 # restoring 
    
    sw  $v0 , 4($a0)  # storing randX into objects structure 
    
    move $t2 , $v0  # storing x into $t2
    
    jal randY # getting randY
    
    lw   $s0 , 4($sp) # loading pointer
    move $a0,$s0 # restoring 
    
    sw  $v0 , 8($a0)  # storing randY into objects structure
       
    
    lw       $t0 , linelen
	mult     $v0 , $t0    # multiply linelen and Y coord
    mflo     $t1         # storing answer in $t1
    add      $t1 , $t1 , $t2   # adding (Y*linelen)+ X
    sw       $t1 , 0($a0)     # storing pointer to location in board of object
    lw  $ra , 0($sp) # loading pointer
    addi $sp , $sp , 8  # clearing stack pointer 
jr $ra
    
    
    
########################################################################
# Function Name: bool moveRobot(idx)
########################################################################
# Functional Description:
# The $a0 register is the index of an object (a robot or rubble).
# This computes and moves the robot to take one step closer to the
# person. If the robot crashes, it becomes rubble. This routine returns
# 1 if the person was killed by a robot; 0 otherwise.
#
########################################################################
# Register Usage in the Function:
# $a0 -- Index of object in question
# $s0 -- saved index of object in question.
# $s1 -- pointer to the object's structure.
# $s2 -- pointer to the player's structure.
# $t0, $t1 -- general calculations.
# $v0 -- subroutine linkage
#
########################################################################
# Algorithmic Description in Pseudocode:
# 1. Save registers on stack
# 2. Compute pointers to object's struct and player's struct
# 3. If object is a robot:
# 3a. See what is in map at robot's location. Normally it would be
# the robot symbol. But if another robot had crashed into
# this one, it would be rubble. If it is rubble, turn this
# robot object into a rubble object.
# 3b. Erase the robot from the map
# 3c. Move the robot one step vertically closer to player
# 3d. Move the robot one step horizontally closer to player
# 3e. See if there is a collision at this location
# 3f. Draw robot back into map
# 4. Restore registers
#
########################################################################
  
moveRobot: 
   
    move  $v1 , $a0
    sw    $ra , -4($sp)   # loading return address into stack 
    sub   $sp , $sp , 4
    addi  $s1 , $a0 , 0    # holding pointer to object 
    la    $a0  , objects    # loading objects address to hold player pointer
    addi  $s2 , $a0 , 0    # holding pointer to player 
    addi  $t0  ,$0 ,  2    # need to compare if robot 
    
    lw    $t1 , 12($s1)    # loading type of object 
    
    beq   $t0 , $t1 , isRobot  # if object is robot branch 
    
    
    
    
    
    isRobot: 	# make another $t that holds the p and if it colides with p then leave
    	addi $t2 , $0 , 46 # holds *
    	lw   $t1 , 0($s1)  # loading address of robot on board
    	move $a0,$s1      # need in order to call whatthere
    	jal  whatthere    # checking to see symbol is on the board
    	beq  $v0 , $t2, hitRubble # go to hit rubble if equal 
    	
    backToRo:
    	move $a0 , $s1 # need in order to call eraseobj
    	jal eraseobj  # erasing object
    	lw  $t0 , 4($s2) # player x location 
    	lw  $t1 , 4($s1) # robot x location
    	lw  $t3 , 12($s1)
    	addi $t4, $0 , 3
    	beq $t3 , $t4 , backAgain
    	
    	
    	ble  $t0 , $t1 , moveMeLeft  # move left because playerx < robotx
    	move $a0 , $v1
    	jal movee  # go to move right function 
    checkY:
    	lw  $t0 , 8($s2) # player y location 
    	lw  $t1 , 8($s1) # robot y location
    	ble  $t0 , $t1 , moveMeUp  # move up because playery < roboty
    	move $a0 , $v1
    	jal moves  # go to move down function 
    	
    	
    afterChecks: 
    	
    	jal whatthere # see whats on board 
    	lw   $t0 , 0($s1) 
    	la   $a0 ,board
    	add  $a0 , $a0, $t0 # want a to point at location of object
    	addi $t1 ,$0 , 46  # storing "." into $t1 char code
    	bne  $v0, $t1 , hitRubbleTwo # if not equal to "." hit collision 
    		
    backAgain:
    	move  $a0 , $s1  # need to move to call drawobj
    	jal   drawobj        # calling drawobj
    	lw    $ra , 0($sp)   # loading return address from stack
    	addi  $ra , $ra , 4 # returning stack pointer to normal
    	addi $s1 , $0 , 0
    	addi $s2 , $0 , 0
    	
    	jr $ra 
    	
    	
    	
    		
    	
    hitRubble:
    	addi $t2 , $0 ,3 # turning into rubble 
    	sw   $t2 , 12($s1)  # ^^^^^^
    	beq  $v0 , $t6 , leave
    	j backToRo
        
	
    moveMeLeft:
    move $a0 , $v1
    	jal movew  # go to move left function 
        j checkY # going to check y now 
    
    
    moveMeUp:
    move $a0 , $v1
    	jal moven # go to move north function
    	j afterChecks
    
    hitRubbleTwo:
    	addi $t2 , $0 ,3 # turning into rubble 
    	sw   $t2 , 12($s1)  # ^^^^^^
    	addi $t1 ,$0 ,46   # storing * into $t1 char code
    	move $a0,$s1  
    	jal  whatthere    # checking to see symbol is on the boa
    	
    	bne  $t1 , $v0 , backAgain # if collison not with player go back
    	addi $v0 , $0 , 1 # hold a 1 for player killed 
    	j leave
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

