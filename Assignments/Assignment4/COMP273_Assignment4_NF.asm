# TODO: NICOLAS FERTOUT - 260826282
# TODO: Please waive my late penalty on this assignment.
# TODO: SEE LABELS FOR PROCEDURES YOU MUST IMPLEMENT AT THE BOTTOM OF THIS FILE

.data
TestNumber:	.word 2		# TODO: Which test to run!
				# 0 compare matrices stored in files Afname and Bfname
				# 1 test Proc using files A through D named below
				# 2 compare MADD1 and MADD2 with random matrices of size Size
				
Proc:		MADD2		# Procedure used by test 2, set to MADD1 or MADD2		
				
Size:		.word 64		# matrix size (MUST match size of matrix loaded for test 0 and 1)

Afname: 		.asciiz "A64.bin"
Bfname: 		.asciiz "B64.bin"
Cfname:		.asciiz "C64.bin"
Dfname:	 	.asciiz "D64.bin"

#################################################################
# Main function for testing assignment objectives.
# Modify this function as needed to complete your assignment.
# Note that the TA will ultimately use a different testing program.
.text
main:		la $t0 TestNumber
		lw $t0 ($t0)
		beq $t0 0 compareMatrix
		beq $t0 1 testFromFile
		beq $t0 2 compareMADD
		li $v0 10 # exit if the test number is out of range
        		syscall	

compareMatrix:	la $s7 Size	
		lw $s7 ($s7)		# Let $s7 be the matrix size n

		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix A
		move $s0 $v0		# $s0 is a pointer to matrix A
		la $a0 Afname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s0
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix B
		move $s1 $v0		# $s1 is a pointer to matrix B
		la $a0 Bfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s1
		jal loadMatrix
	
		move $a0 $s0
		move $a1 $s1
		move $a2 $s7
		jal check
		
		li $v0 10      	# load exit call code 10 into $v0
        		syscall         	# call operating system to exit	

testFromFile:	la $s7 Size	
		lw $s7 ($s7)		# Let $s7 be the matrix size n

		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix A
		move $s0 $v0		# $s0 is a pointer to matrix A
		la $a0 Afname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s0
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix B
		move $s1 $v0		# $s1 is a pointer to matrix B
		la $a0 Bfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s1
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix C
		move $s2 $v0		# $s2 is a pointer to matrix C
		la $a0 Cfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s2
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix A
		move $s3 $v0		# $s3 is a pointer to matrix D
		la $a0 Dfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s3
		jal loadMatrix		# D is the answer, i.e., D = AB+C 
	
		# TODO: add your testing code here
		move $a0, $s0	# A
		move $a1, $s1	# B
		move $a2, $s2	# C
		move $a3, $s7	# n
		
		la $ra ReturnHere
		la $t0 Proc	# function pointer
		lw $t0 ($t0)	
		jr $t0		# like a jal to MADD1 or MADD2 depending on Proc definition

ReturnHere:	move $a0 $s2	# C
		# move $a0 $v0	# C
		move $a1 $s3	# D
		move $a2 $s7	# n
		jal check	# check the answer

		li $v0, 10      	# load exit call code 10 into $v0
	        	syscall         	# call operating system to exit	

compareMADD:	la $s7 Size
		lw $s7 ($s7)	# n is loaded from Size
		mul $s4 $s7 $s7	# n^2
		sll $s5 $s4 2	# n^2 * 4

		move $a0 $s5
		li   $v0 9	# malloc A
		syscall	
		move $s0 $v0
		move $a0 $s5	# malloc B
		li   $v0 9
		syscall
		move $s1 $v0
		move $a0 $s5	# malloc C1
		li   $v0 9
		syscall
		move $s2 $v0
		move $a0 $s5	# malloc C2
		li   $v0 9
		syscall
		move $s3 $v0	
	
		move $a0 $s0	# A
		move $a1 $s4	# n^2
		jal  fillRandom	# fill A with random floats
		move $a0 $s1	# B
		move $a1 $s4	# n^2
		jal  fillRandom	# fill A with random floats
		move $a0 $s2	# C1
		move $a1 $s4	# n^2
		jal  fillZero	# fill A with random floats
		move $a0 $s3	# C2
		move $a1 $s4	# n^2
		jal  fillZero	# fill A with random floats

		move $a0 $s0	# A
		move $a1 $s1	# B
		move $a2 $s2	# C1	# note that we assume C1 to contain zeros !
		move $a3 $s7	# n
		jal MADD1

		move $a0 $s0	# A
		move $a1 $s1	# B
		move $a2 $s3	# C2	# note that we assume C2 to contain zeros !
		move $a3 $s7	# n
		jal MADD2

		move $a0 $s2	# C1
		move $a1 $s3	# C2
		move $a2 $s7	# n
		jal check	# check that they match
	
		li $v0 10      	# load exit call code 10 into $v0
        		syscall         	# call operating system to exit	

###############################################################
# mallocMatrix( int N )
# Allocates memory for an N by N matrix of floats
# The pointer to the memory is returned in $v0	
mallocMatrix: 	mul  $a0, $a0, $a0	# Let $s5 be n squared
		sll  $a0, $a0, 2		# Let $s4 be 4 n^2 bytes
		li   $v0, 9		
		syscall			# malloc A
		jr $ra
	
###############################################################
# loadMatrix( char* filename, int width, int height, float* buffer )
.data
errorMessage: .asciiz "FILE NOT FOUND" 
.text
loadMatrix:	mul $t0 $a1 $a2 	# words to read (width x height) in a2
		sll $t0 $t0  2	  	# multiply by 4 to get bytes to read
		li $a1  0     		# flags (0: read, 1: write)
		li $a2  0     		# mode (unused)
		li $v0  13    		# open file, $a0 is null-terminated string of file name
		syscall
		slti $t1 $v0 0
		beq $t1 $0 fileFound
		la $a0 errorMessage
		li $v0 4
		syscall		  	# print error message
		li $v0 10         	# and then exit
		syscall		
fileFound:	move $a0 $v0     	# file descriptor (negative if error) as argument for read
  		move $a1 $a3     	# address of buffer in which to write
		move $a2 $t0	  	# number of bytes to read
		li  $v0 14       	# system call for read from file
		syscall           	# read from file
		# $v0 contains number of characters read (0 if end-of-file, negative if error).
                	# We'll assume that we do not need to be checking for errors!
		# Note, the bitmap display doesn't update properly on load, 
		# so let's go touch each memory address to refresh it!
		move $t0 $a3	# start address
		add $t1 $a3 $a2  	# end address
loadloop:	lw $t2 ($t0)
		sw $t2 ($t0)
		addi $t0 $t0 4
		bne $t0 $t1 loadloop		
		li $v0 16	# close file ($a0 should still be the file descriptor)
		syscall
		jr $ra	

##########################################################
# Fills the matrix $a0, which has $a1 entries, with random numbers
fillRandom:	li $v0 43
		syscall		# random float, and assume $a0 unmodified!!
		swc1 $f0 0($a0)
		addi $a0 $a0 4
		addi $a1 $a1 -1
		bne  $a1 $zero fillRandom
		jr $ra

##########################################################
# Fills the matrix $a0 , which has $a1 entries, with zero
fillZero:	sw $zero 0($a0)	# $zero is zero single precision float
		addi $a0 $a0 4
		addi $a1 $a1 -1
		bne  $a1 $zero fillZero
		jr $ra



######################################################
# TODO: void subtract( float* A, float* B, float* C, int N )  C = A - B 
subtract: 	
		# Assume A and B are adresses stored in $a0 and $a1 respectively,
		# N will be stored in $a2 as input.
		# Return value (i.e. adress of C) will be stored in $v0.
		
		# get n^2 to get the number of element to iterate through:
		mul $t1, $a2, $a2
		# muliply by 4 to get size (by shifting)
		sll $t1, $t1, 2
		
		# So here, $t1 contains the size (in bytes) taken by the matrix
		
		# CAREFUL: element #1 is at adress 0, so element n^2 is at adress 4*n^2 - 4
		# Terminating condition will therefore be i < 4*n^2 (strictly less)
		# (incrementing the counter by 4 everytime)
		
		
		# initialize the array adresses iterator
		addi $t0, $zero, 0
		
		# push onto stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		# subtract
		jal SubtractLoop
		
		# reset pointers
		sub $a0, $a0, $t1 
		sub $a1, $a1, $t1 
		sub $v0, $v0, $t1 
		# we subtract by 4*n^2 (and not by  4*n^2 - 4), because we also increased pointers on last iteration
		
		# pop from stack
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
		
SubtractLoop:
		# We assume that the size of the matrix is always > 0 (>=1)
		# So the terminating condition is at the end of the loop

		# get current entries 
		lwc1 $f4, 0($a0)	# A_ij
		lwc1 $f6, 0($a1)	# B_ij
		
		# subtract
		sub.s $f8, $f4, $f6 # A_ij - B_ij
		
		# store new entry
		swc1 $f8, 0($v0)
		
		# increment matrix pointer
		addi $a0, $a0, 4
		addi $a1, $a1, 4
		addi $v0, $v0, 4
		
		# increase iterator
		addi $t0, $t0, 4
		
		# terminating condition
		# if ($t0 < $t1) == 0, then we are done
		sltu $t7, $t0, $t1 # recall $t1 stores the total space of a matrix of size n
		beq $t7, $zero, Done
		
		j SubtractLoop
		

#################################################
# TODO: float frobeneousNorm( float* A, int N )
frobeneousNorm: 
		# Assume the adress of A is stored in $a0,
		# and N in $a2 as input.
		# Return value will be stored in $f0.
		
		# get n^2 to get the number of element to iterate through:
		mul $t1, $a2, $a2
		# muliply by 4 to get size (by shifting)
		sll $t1, $t1, 2
		
		# So here, $t1 contains the size (in bytes) taken by the matrix
		
		# initialize the array adresses iterator
		addi $t0, $zero, 0
		
		# push onto stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		# compute sum of squares
		sub.s $f8, $f8, $f8 # to make sure value is 0, will be returned by helper procedure
		jal FrobeneousLoop
		
		# take square root and store final result in $f0
		sqrt.s $f0, $f8
		
		# reset pointer
		sub $a0, $a0, $t1 
		
		# pop from stack
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra
		
		
FrobeneousLoop:
		# We assume that the size of the matrix is always > 0 (>=1)
		# So the terminating condition is at the end of the loop

		# get current entry 
		lwc1 $f4, 0($a0)	# A_ij
		
		# Square
		mul.s $f6, $f4, $f4 # (A_ij)^2
		
		# Sum
		add.s $f8, $f8, $f6 # Sum = Sum + (A_ij)^2
		
		# increment matrix pointer
		addi $a0, $a0, 4

		# increase iterator
		addi $t0, $t0, 4
		
		# terminating condition
		# if ($t0 < $t1) == 0, then we are done
		sltu $t7, $t0, $t1 # recall $t1 stores the total space of a matrix of size n
		beq $t7, $zero, Done
		
		j FrobeneousLoop
		
		
#################################################
# TODO: void check ( float* C, float* D, int N )
# Print the forbeneous norm of the difference of C and D
check: 		
		# Assume C and D are adresses stored in $a0 and $a1 respectively,
		# N will be stored in $a2 as input.		

		# push onto stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		
		# since return adress is $v0, we want it to be A (= $a0) 
		move $v0, $a0 
		# call subtract(A, B, A, n) = subtract($a0, $a1, $v0 (= $a0), $a2)
		jal subtract 
		
		# result is now stored in $v0 = A = $a0
		
		# call frobeneousNorm(A, n), with new modified A = $a0
		jal frobeneousNorm 
		
		# result is now stored in $f0
				
		# print float result
		mov.s $f12, $f0
		li $v0, 2
		syscall
		
		# pop from stack
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra

##############################################################
# TODO: void MADD1( float*A, float* B, float* C, N )
MADD1: 		
		# Assume A, B and C are adresses stored in $a0, $a1 and $a2 respectively,
		# N will be stored in $a3 as input.
		# Return value (i.e. adress of C) will be stored in $v0.
		
		# push onto stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		# get n^2 to get the number of element to iterate through:
		mul $t1, $a3, $a3
		# muliply by 4 to get size (by shifting)
		sll $t1, $t1, 2
		
		# get 4n
		sll $t6, $a3, 2 
		
		# initialize the array adresses iterators
		addi $t0, $zero, 0 # general iterator
		
		# 	0	0	0
		# 	X	X	XB
		# 	X	X	X
		# 	XA	X	X
		# 	0	0	0
		
		
		jal MADD1OuterLoop
		
		
		add $a0, $a0, $a3 # A* = A* + n
		add $a0, $a0, $a3 # A* = A* + n
		add $a0, $a0, $a3 # A* = A* + n
		add $a0, $a0, $a3 # A* = A* + n
		
		addi $a1, $a1, 4 # B* = B* + 4
		# reset pointers
		sub $a0, $a0, $t1 # A* = A* - 4n^2
		sub $a1, $a1, $a3 # B* = B* - n
		sub $a1, $a1, $a3 # B* = B* - n
		sub $a1, $a1, $a3 # B* = B* - n
		sub $a1, $a1, $a3 # B* = B* - n
		sub $a2, $a2, $t1 # C* = C* - 4n^2
		
		# set $v0 to be the adress of C
		add $v0, $s2, $zero
		
		# pop from stack
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra

MADD1OuterLoop:
		# check if first iteration
		beq $t0, $zero, MADD1OuterLoopCtd
		
		# increase B pointer if we didn't trigger the above conditions
		addi $a1, $a1, 4
		
		# reset iterators conditions
		# check if general iterator = 0 [mod 4n]
		div $t0, $t6
		mfhi $t7
		# if result is 0 and general iterator is not 0, reset j and increase i
		beq $t7, $zero, UpdatePointers
		
		
		j MADD1OuterLoopCtd

UpdatePointers:
		# increase A pointer by 4n 
		add $a0, $a0, $a3 # + n  
		add $a0, $a0, $a3 # + n  
		add $a0, $a0, $a3 # + n  
		add $a0, $a0, $a3 # + n  
		
		# and reset B pointer
		sub $a1, $a1, $t6
		
		j MADD1OuterLoopCtd
		
MADD1OuterLoopCtd:
		# push onto stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		
		# get value of C
		lwc1 $f4, 0($a2)
		
		# initialize the iterator
		addi $t4, $zero, 0
		
		# update value with product C_ij = [A*B]_ij	
		jal MADD1InnerLoop
		
		# store new value in C_ij = [A*B]_ij	
		#swc1 $f4, 0($v0)
		swc1 $f4, 0($a2)
		
		# here B pointer is at the element "below" the last of the column and
		# A at the first of the next row
		
		# reset them
		# decrease A pointer by 4n 
		sub $a0, $a0, $a3 # - n  
		sub $a0, $a0, $a3 # - n  
		sub $a0, $a0, $a3 # - n  
		sub $a0, $a0, $a3 # - n  
		
		# decrease B pointer by 4n^2
		subu $a1, $a1, $t1
		
		# increase general iterator
		addi $t0, $t0, 4
		
		# increase pointers
		addi $a2, $a2, 4 # C before
		addi $v0, $v0, 4 # C = A - B
		
		# pop from stack
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		# terminating condition
		# if ($t0 < $t1) == 0, then we are done
		sltu $t7, $t0, $t1 # recall $t1 stores the total space of a matrix of size n
		beq $t7, $zero, Done
		
		
		j MADD1OuterLoop


MADD1InnerLoop:
		
		# get value of A_ik and B_kj from $a0 and $a1, in $f4 and $f6
		lwc1 $f6, 0($a0) # A_ik
		lwc1 $f8, 0($a1) # B_kj
		
		# temp = A_ik*B_kj, in $f10
		mul.s $f10, $f6, $f8
		
		# C = C + temp = $f4 + $f10, in $f10
		add.s $f4, $f4, $f10
		
		# increment pointers
		addi $a0, $a0, 4 # A* = A* + 4
		
		add $a1, $a1, $a3 # B* = B* + n
		add $a1, $a1, $a3 # B* = B* + n
		add $a1, $a1, $a3 # B* = B* + n
		add $a1, $a1, $a3 # B* = B* + n
		
		# increment iterator
		addi $t4, $t4, 1
		
		# terminating condition
		# if ($t4 < $a3) == 0, Done
		slt $t7, $t4, $a3
		beq $t7, $zero, Done
		
		j MADD1InnerLoop


#########################################################
# TODO: void MADD2( float*A, float* B, float* C, N )
MADD2: 		
		# Assume A, B and C are adresses stored in $a0, $a1 and $a2 respectively,
		# N will be stored in $a3 as input.
		# Return value (i.e. adress of C) will be stored in $v0.
		
		# push onto stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		# initialize the array adresses iterators
		addi $t0, $zero, 0 # jj = 0
		addi $t1, $zero, 0 # kk = 0
		addi $t2, $zero, 0 # i = 0
		addi $t3, $zero, 0 # j = 0
		addi $t4, $zero, 0 # k = 0
		
		jal LoopJJ
		
		# set $v0 to be the adress of C
		add $v0, $a2, $zero

		# pop from stack
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra


LoopJJ:
		# terminating condition
		# if ($t0 < $a3 (= n)) == 0, then we are done
		bge $t0, $a3, Done
		
		addi $t1, $zero, 0 # kk = 0
		
		j LoopKK

LoopKK:
		# terminating condition
		# if ($t1 < $a3 (= n)) == 0, then we are done
		bge $t1, $a3, DoneKK
		
		addi $t2, $zero, 0 # i = 0
		
		j LoopI
		
DoneKK:
		# increment jj
		addi $t0, $t0, 4
		
		j LoopJJ

LoopI:	
		# terminating condition
		# if ($t2 < $a3 (= n)) == 0, then we are done
		bge $t2, $a3, DoneI
		
		addi $t3, $t0, 0 # j = jj
		
		j LoopJ

DoneI:
		# increment kk
		addi $t1, $t1, 4
		
		j LoopKK

LoopJ:
		# terminating conditions
		# if ($t3 < $a3 (= n)) == 0, then we are done
		bge $t3, $a3, DoneJ
		# if ($t3 < ($t0 + 4) (= jj + bsize)) == 0, then we are done
		addi $t8, $t0, 4 # get jj + bsize
		bge $t3, $t8, DoneJ
		
		addi $t4, $t1, 0 # k = kk
		
		sub.s $f4, $f4, $f4 # sum = 0.0
		
		j LoopK

DoneJ:		
		# increment i
		addi $t2, $t2, 1
		
		j LoopI

LoopK:
		# get current adresses of A 
		move $t7, $a0
		
		# given i, j and k,:
		# A* = 0(A) + 4*(n*i) + 4*k = 0(A) + 4*(n*i + k)
		mul $t9, $t2, $a3 # n*i
		add $t9, $t9, $t4 # n*i + k
		sll $t9, $t9, 2 # 4*(n*i + k)
		add $t7, $t7, $t9 # 0(A) + 4*(n*i + k)
		
		# get A_ik
		lwc1 $f8, 0($t7)
		
		# get current adresses of B
		move $t8, $a1
		
		# B* = 0(B) + 4*(n*k) + 4*j = 0(B) + 4*(n*k + j)
		mul $t9, $t4, $a3 # n*k
		add $t9, $t9, $t3 # n*k + j
		sll $t9, $t9, 2 # 4*(n*k + j)
		add $t8, $t8, $t9 # 0(B) + 4*(n*k + j)
		
		# get B_kj
		lwc1 $f10, 0($t8)
		
		# computations:
		# temp = A_ik * B_kj
		mul.s $f16, $f8, $f10
		# sum = sum + temp
		add.s $f4, $f4, $f16
		
		# increment k
		addi $t4, $t4, 1
		
		# terminating conditions
		# if ($t4 < $a3 (= n)) == 0, then we are done
		bge $t4, $a3, DoneK
		# if ($t4 < ($t1 + 4) (= kk + bsize)) == 0, then we are done
		addi $t8, $t1, 4 # get kk + bsize
		bge $t4, $t8, DoneK
		
		j LoopK

DoneK:
		# get current adresses of C
		move $t8, $a2
		
		# C* = 0(C) + 4*(n*i) + 4*j = 0(C) + 4*(n*i + j)
		mul $t9, $t2, $a3 # n*i
		add $t9, $t9, $t3 # n*i + j
		sll $t9, $t9, 2 # 4*(n*i + j)
		add $t8, $t8, $t9 # 0(C) + 4*(n*i + j)
		
		# get C_ij
		lwc1 $f16, 0($t8)
		# C_ij = C_ij + sum
		add.s $f16, $f16, $f4
		# store it back
		swc1 $f16, 0($t8)
		
		# increment j
		addi $t3, $t3, 1 
		
		j LoopJ










##################################################################################################################






































MADD2LoopJJ:
		# push onto stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		addi $t1, $zero, 0 # kk
		
		jal MADD2LoopKK
		
		addi $t0, $t0, 4 # increment jj by bsize = 4
		
		# reset every pointer to the next wanted position 
		# (since we designed the inner reset not to work in this case) car on est con
		# sub $a0, $a0, $t5 # - 4n^2
		sub $a1, $a1, $t5 # - 4n^2
		# sub $a2, $a2, $t5 # - 4n^2
		
		sub $a0, $a0, $t6 # - 4n
		
		# pop from stack
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		# terminating condition
		# if ($t0 < $a3 (= n)) == 0, then we are done
		sltu $t7, $t0, $a3
		beq $t7, $zero, Done
		
		j MADD2LoopJJ


MADD2LoopKK:
		# push onto stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal checkI # reset value of i if it isn't the first iteration
		
		addi $t2, $zero, 0 # i = 0
		
		jal MADD2LoopI
		
		addi $t1, $t1, 4 # increment kk by bsize = 4
		
		# pop from stack
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		# terminating condition
		# if ($t1 < $a3 (= n)) == 0, then we are done
		sltu $t7, $t1, $a3
		beq $t7, $zero, Done
		
		j MADD2LoopKK

###############################################################################################################
checkI:
		# if i != n, Done
		bne $t2, $a3, Done
		# else, C* = C* - 4n^2
		sub $a2, $a2, $t5
		# else, A* = A* - 4n^2
		sub $a0, $a0, $t5
		
		jr $ra
		

MADD2LoopI:
		# push onto stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal checkJ # reset column-pointer if it isn't the first iteration of MADD2LoopI
		
		addi $t3, $t0, 0 # j = jj
		
		jal MADD2LoopJ
		
		addi $t2, $t2, 1 # increment i by 1
		
		# update C pointer (point to next row)
		add $a2, $a2, $t6 # $t6 = 4n
		# update A pointer (point to next row)
		add $a0, $a0, $t6 # $t6 = 4n
		
		# pop from stack
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		# terminating condition
		# if ($t2 < $a3 (= n)) == 0, then we are done
		sltu $t7, $t2, $a3
		beq $t7, $zero, Done
		
		j MADD2LoopI
		
checkJ:
		# if j == n && (n MOD bsize) != 0 then
		# C* = C* - 4*(n MOD bsize)
		# B* = B* - 4*(n MOD bsize)
		addi $t8, $zero, 4
		div $a3, $t8 # n/4
		mfhi $t8
		
		seq $t8, $t8, $zero # = 1 if [(n MOD bsize) == 0]
		seq $t7, $t3, $a3 # = 1 if (j == n)
		ori $t8, $t8, 0xFFFFFFFE # replace everything by one's except LSB
		nor $t8, $t8, $zero # !$t8
		
		and $t8, $t8, $t7
		beq $t8, 1, NBreakJ
		
		# if j != jj+4, Done
		addi $t8, $t0, 4 # jj + bsize
		bne $t3, $t8, Done
		# else, C* = C* - 16
		subiu $a2, $a2, 16
		# else, B* = B* - 16
		subiu $a1, $a1, 16
		
		jr $ra

NBreakJ:	
		# get (n MOD bsize)
		addi $t8, $zero, 4
		div $a3, $t8 # n/4
		mfhi $t8 # this is (n MOD bsize)
		sll $t8, $t8, 2 # this is 4*(n MOD bsize)
		# C* = C* - 4*(n MOD bsize)
		subu $a2, $a2, $t8
		# B* = B* - 4*(n MOD bsize)
		subu $a1, $a1, $t8
		
		jr $ra


MADD2LoopJ:
		# push onto stack
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		# CHECK K!!!!!!!!!!!!!!!!!
		jal checkK
		
		addi $t4, $t1, 0# k = kk
		
		sub.s $f4, $f4, $f4 # sum = 0.0
		
		jal MADD2LoopK
		
		# access value of C_ij
		lwc1 $f6, 0($a2)
		# C_ij = C_ij + sum
		add.s $f6, $f6, $f4
		# store it back
		swc1 $f6, 0($a2)
		
		addi $t3, $t3, 1 # increment j by 1
		
		# update C pointer
		addi $a2, $a2, 4
		
		# update B pointer
		addi $a1, $a1, 4
		
		# pop from stack
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		# terminating conditions
		# if ($t3 < $a3 (= n)) == 0, then we are done
		sltu $t7, $t3, $a3
		beq $t7, $zero, Done
		# if ($t3 < ($t0 + 4) (= jj + bsize)) == 0, then we are done
		addi $t8, $t0, 4 # get jj + bsize
		sltu $t7, $t3, $t8
		beq $t7, $zero, Done
		
		j MADD2LoopJ

checkK:
		# if k == n && (n MOD bsize) != 0 then
		# A* = A* - 4*(n MOD bsize)
		# B* = B* - 4n*(n MOD bsize)
		addi $t8, $zero, 4
		div $a3, $t8 # n/4
		mfhi $t8
		
		seq $t8, $t8, $zero # = 1 if [(n MOD bsize) == 0]
		seq $t7, $t4, $a3 # = 1 if (k == n)
		ori $t8, $t8, 0xFFFFFFFE # replace everything by one's except LSB
		nor $t8, $t8, $zero # !$t8
		
		and $t8, $t8, $t7
		beq $t8, 1, NBreakK
		
		
		# if k != kk+4, Done
		addi $t8, $t1, 4 # kk + bsize
		bne $t4, $t8, Done
		# else, A* = A* - 4*4
		subiu $a0, $a0, 16
		# else, B* = B* - 4*(4n)
		subu $a1, $a1, $t6
		subu $a1, $a1, $t6
		subu $a1, $a1, $t6
		subu $a1, $a1, $t6
		
		jr $ra

NBreakK:
		# get (n MOD bsize)
		addi $t8, $zero, 4
		div $a3, $t8 # n/4
		mfhi $t8 # this is (n MOD bsize)
		sll $t8, $t8, 2 # this is 4*(n MOD bsize)
		# A* = A* - 4*(n MOD bsize)
		subu $a0, $a0, $t8
		
		mul $t8, $t8, $a3 # this is 4*(n MOD bsize)*n
		# B* = B* - 4n*(n MOD bsize)
		subu $a1, $a1, $t8
		
		jr $ra
		

MADD2LoopK:
		# get A_ik
		lwc1 $f8, 0($a0)
		# get B_kj
		lwc1 $f10, 0($a1)
		
		# temp = A_ik * B_kj
		mul.s $f16, $f8, $f10
		
		# sum = sum + temp
		add.s $f4, $f4, $f16
		
		# increment iterator
		addi $t4, $t4, 1
		
		# update pointers:
		
		# A* = A* + 4
		addi $a0, $a0, 4
		# B* = B* + 4n
		add $a1, $a1, $t6
		
		# terminating conditions
		# if ($t4 < $a3 (= n)) == 0, then we are done
		sltu $t7, $t4, $a3
		beq $t7, $zero, Done
		# if ($t4 < ($t1 + 4) (= kk + bsize)) == 0, then we are done
		addi $t8, $t1, 4 # get kk + bsize
		sltu $t7, $t4, $t8
		beq $t7, $zero, Done
		
		j MADD2LoopK


#########################################################
# Generic DONE procedure
Done:
		jr   $ra






