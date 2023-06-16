# Nicolas FERTOUT, 260826282
# TODO: ADD OTHER COMMENTS YOU HAVE HERE AT THE TOP OF THIS FILE
# TODO: SEE LABELS FOR PROCEDURES YOU MUST IMPLEMENT AT THE BOTTOM OF THIS FILE
# TODO: NOTICE THE TODO IN THE .DATA SEGMENT
# TODO: RENAME THIS FILE AS PER THE SUBMISSION REQUIREMENTS

# Menu options
# r - read text buffer from file 
# p - print text buffer
# e - encrypt text buffer
# d - decrypt text buffer
# w - write text buffer to file
# g - guess the key
# q - quit

.data
MENU:              .asciiz "Commands (read, print, encrypt, decrypt, write, guess, quit):"
REQUEST_FILENAME:  .asciiz "Enter file name:"
REQUEST_KEY: 	 .asciiz "Enter key (upper case letters only):"
REQUEST_KEYLENGTH: .asciiz "Enter a number (the key length) for guessing:"
REQUEST_LETTER: 	 .asciiz "Enter guess of most common letter:"
ERROR:		 .asciiz "There was an error.\n"

ARRAY_FREQ:	.word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 # Array to store letter frequency for Q3

FILE_NAME: 	.space 256	# maximum file name length, should not be exceeded
KEY_STRING: 	.space 256 	# maximum key length, should not be exceeded

.align 2		# ensure word alignment in memory for text buffer (not important)
TEXT_BUFFER:  	.space 10000
.align 2		# ensure word alignment in memory for other data (probably important)
# TODO: define any other spaces you need, for instance, an array for letter frequencies



##############################################################
.text
		move $s1 $0 	# Keep track of the buffer length (starts at zero)
MainLoop:	li $v0 4		# print string
		la $a0 MENU
		syscall
		li $v0 12	# read char into $v0
		syscall
		move $s0 $v0	# store command in $s0			
		jal PrintNewLine

		beq $s0 'r' read
		beq $s0 'p' print
		beq $s0 'w' write
		beq $s0 'e' encrypt
		beq $s0 'd' decrypt
		beq $s0 'g' guess
		beq $s0 'q' exit
		b MainLoop

read:		jal GetFileName
		li $v0 13	# open file
		la $a0 FILE_NAME 
		li $a1 0		# flags (read)
		li $a2 0		# mode (set to zero)
		syscall
		move $s0 $v0
		bge $s0 0 read2	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		b MainLoop
read2:		li $v0 14	# read file
		move $a0 $s0
		la $a1 TEXT_BUFFER
		li $a2 9999
		syscall
		move $s1 $v0	# save the input buffer length
		bge $s0 0 read3	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		move $s1 $0	# set buffer length to zero
		la $t0 TEXT_BUFFER
		sb $0 ($t0) 	# null terminate the buffer 
		b MainLoop
read3:		la $t0 TEXT_BUFFER
		add $t0 $t0 $s1
		sb $0 ($t0) 	# null terminate the buffer that was read
		li $v0 16	# close file
		move $a0 $s0
		syscall
		la $a0 TEXT_BUFFER
		jal ToUpperCase
print:		la $a0 TEXT_BUFFER
		jal PrintBuffer
		b MainLoop	

write:		jal GetFileName
		li $v0 13	# open file
		la $a0 FILE_NAME 
		li $a1 1		# flags (write)
		li $a2 0		# mode (set to zero)
		syscall
		move $s0 $v0
		bge $s0 0 write2	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		b MainLoop
write2:		li $v0 15	# write file
		move $a0 $s0
		la $a1 TEXT_BUFFER
		move $a2 $s1	# set number of bytes to write
		syscall
		bge $v0 0 write3	# negative means error
		li $v0 4		# print string
		la $a0 ERROR
		syscall
		b MainLoop
		write3:
		li $v0 16	# close file
		move $a0 $s0
		syscall
		b MainLoop

encrypt:		jal GetKey
		la $a0 TEXT_BUFFER
		la $a1 KEY_STRING
		jal EncryptBuffer
		la $a0 TEXT_BUFFER
		jal PrintBuffer
		b MainLoop

decrypt:		jal GetKey
		la $a0 TEXT_BUFFER
		la $a1 KEY_STRING
		jal DecryptBuffer
		la $a0 TEXT_BUFFER
		jal PrintBuffer
		b MainLoop

guess:		li $v0 4		# print string
		la $a0 REQUEST_KEYLENGTH
		syscall
		li $v0 5		# read an integer
		syscall
		move $s2 $v0
		
		li $v0 4		# print string
		la $a0 REQUEST_LETTER
		syscall
		li $v0 12	# read char into $v0
		syscall
		move $s3 $v0	# store command in $s0			
		jal PrintNewLine

		move $a0 $s2
		la $a1 TEXT_BUFFER
		la $a2 KEY_STRING
		move $a3 $s3
		jal GuessKey
		li $v0 4		# print String
		la $a0 KEY_STRING
		syscall
		jal PrintNewLine
		b MainLoop

exit:		li $v0 10 	# exit
		syscall

###########################################################
PrintBuffer:	li $v0 4          # print contents of a0
		syscall
		li $v0 11	# print newline character
		li $a0 '\n'
		syscall
		jr $ra

###########################################################
PrintNewLine:	li $v0 11	# print char
		li $a0 '\n'
		syscall
		jr $ra

###########################################################
PrintSpace:	li $v0 11	# print char
		li $a0 ' '
		syscall
		jr $ra

#######################################################
GetFileName:	addi $sp $sp -4
		sw $ra ($sp)
		li $v0 4		# print string
		la $a0 REQUEST_FILENAME
		syscall
		li $v0 8		# read string
		la $a0 FILE_NAME  # up to 256 characters into this memory
		li $a1 256
		syscall
		la $a0 FILE_NAME 
		jal TrimNewline
		lw $ra ($sp)
		addi $sp $sp 4
		jr $ra

###########################################################
GetKey:		addi $sp $sp -4
		sw $ra ($sp)
		li $v0 4		# print string
		la $a0 REQUEST_KEY
		syscall
		li $v0 8		# read string
		la $a0 KEY_STRING  # up to 256 characters into this memory
		li $a1 256
		syscall
		la $a0 KEY_STRING
		jal TrimNewline
		la $a0 KEY_STRING
		jal ToUpperCase
		lw $ra ($sp)
		addi $sp $sp 4
		jr $ra

###########################################################
# Given a null terminated text string pointer in $a0, if it contains a newline
# then the buffer will instead be terminated at the first newline
TrimNewline:	lb $t0 ($a0)
		beq $t0 '\n' TNLExit
		beq $t0 $0 TNLExit	# also exit if find null termination
		addi $a0 $a0 1
		b TrimNewline
TNLExit:		sb $0 ($a0)
		jr $ra

##################################################
# converts the provided null terminated buffer to upper case
# $a0 buffer pointer
ToUpperCase:	lb $t0 ($a0)
		beq $t0 $zero TUCExit
		blt $t0 'a' TUCSkip
		bgt $t0 'z' TUCSkip
		addi $t0 $t0 -32	# difference between 'A' and 'a' in ASCII
		sb $t0 ($a0)
TUCSkip:		addi $a0 $a0 1
		b ToUpperCase
TUCExit:		jr $ra

###################################################
# END OF PROVIDED CODE... 
# TODO: use this space below to implement required procedures
###################################################






##################################################
# null terminated buffer is in $a0
# null terminated key is in $a1
EncryptBuffer:	# TODO: Implement this function!

		# will be used to reset the adress of the key
		la $t7, 0($a1)
		
		# push $ra on stack
		addi $sp, $sp, -4 # move stack pointer
		sw $ra, 0($sp) # store current $ra in stack
		
		jal Loop1
		
		# pop $ra from stack
		lw $ra, 0($sp) # store current $ra in stack
		addi $sp, $sp, 4 # move stack pointer to original position
		
		jr $ra
		
Loop1:
		lb $t2, ($a0) # load first char of text
		lb $t3, ($a1) # load first char of key
			
		beq $t2, $zero, ExitText # exit condition for text
		beq $t3, $zero, ExitKey # exit condition for key (important: IF WE DID NOT EXIT TEXT)
		
		# check if it is a letter
		sltiu $t8, $t2, 65
		sltiu $t9, $t2, 91
		ori $t9, $t9, 0xFFFFFFFE # replace everything by one's except LSB
		nor $t9, $t9, $zero # not
		or $t9, $t8, $t9
		# if not, skip
		bne $t9, $zero, SkipLoop1
		
		# encryption of character:
		add $t2, $t2, $t3
		addi $t2, $t2, -65
		
		# if result is greater than ASCII of Z, remove 26
		sltiu $t8, $t2, 91
		beq $t8, $zero, Modulo
		
		# else, do the remaining part of the loop (Loop2)
		j Loop2
		
Loop2:		
		# store char into new string
		sb $t2, ($a0)
		
		# iteration process:
		addi $a0, $a0, 1 # iterate through the text
		addi $a1, $a1, 1 # iterate thourgh the key

		j Loop1

SkipLoop1:
		addi $a0, $a0, 1 # iterate through new string
		addi $a1, $a1, 1 # iterate thourgh the key
		j Loop1
		
Modulo:
		# remove 26 so that we still have a letter
		addi $t2, $t2, -26
		j Loop2
				
ExitText:
		# we are done, yayy
		jr $ra
			
ExitKey:
		# we reached the end of the Key pointer:
		la $a1, 0($t7) # reset Key pointer
		j Loop1 # keep going until Text is over
		
		

##################################################
# null terminated buffer is in $a0
# null terminated key is in $a1
DecryptBuffer:	# TODO: Implement this function!

		# will be used to reset the adress of the key
		la $t7, 0($a1)
		
		# push $ra on stack
		addi $sp, $sp, -4 # move stack pointer
		sw $ra, 0($sp) # store current $ra in stack
		
		jal Loop3
		
		# pop $ra from stack
		lw $ra, 0($sp) # store current $ra in stack
		addi $sp, $sp, 4 # move stack pointer to original position
		
		jr $ra
		
Loop3:
		lb $t2, ($a0) # load first char of text
		lb $t3, ($a1) # load first char of key
			
		beq $t2, $zero, ExitTextBis # exit condition for text
		beq $t3, $zero, ExitKeyBis # exit condition for key (important: IF WE DID NOT EXIT TEXT)
		
		# check if it is a letter
		sltiu $t8, $t2, 65
		sltiu $t9, $t2, 91
		ori $t9, $t9, 0xFFFFFFFE # replace everything by one's except LSB
		nor $t9, $t9, $zero # not
		or $t9, $t8, $t9
		# if not, skip
		bne $t9, $zero, SkipLoop3
		
		# encryption of character:
		sub $t2, $t2, $t3
		addi $t2, $t2, 65
		
		# if result is smaller than ASCII of A, add 26
		sltiu $t8, $t2, 65
		bne $t8, $zero, ModuloInverse
		
		# else, do the remaining part of the loop (Loop2)
		j Loop4
		
Loop4:		
		# store char into new string
		sb $t2, ($a0)
		
		# iteration process:
		addi $a0, $a0, 1 # iterate through the text
		addi $a1, $a1, 1 # iterate thourgh the key

		j Loop3

SkipLoop3:
		addi $a0, $a0, 1 # iterate through new string
		addi $a1, $a1, 1 # iterate thourgh the key
		j Loop3
		
ModuloInverse:
		# remove 26 so that we still have a letter
		addi $t2, $t2, 26
		j Loop4
				
ExitTextBis:
		# we are done, yayy
		jr $ra
			
ExitKeyBis:
		# we reached the end of the Key pointer:
		la $a1, 0($t7) # reset Key pointer
		j Loop3 # keep going until Text is over
		


###########################################################
# a0 keySize - size of key length to guess
# a1 Buffer - pointer to null terminated buffer to work with
# a2 KeyString - on return will contain null terminated string with guess
# a3 common letter guess - for instance 'E' 
GuessKey:	# TODO: Implement this function!
		
		la $t0, 0($a1) # constant = to adress of first char of $a1
		la $t6, 0($a2) # constant = to adress of first char of $a2
		
		la $t1, ARRAY_FREQ # to iterate
		la $t2, ARRAY_FREQ # constant that keeps adress for future resets
		
		# push $ra on stack
		addi $sp, $sp, -4 # move stack pointer
		sw $ra, 0($sp) # store current $ra in stack
		
		# create enough space to store the key in $a2
		li $t3, 1 # iterator 
		jal CreateSpace
		# add null-terminating condition
		sb $zero, 0($a2)
		# reset pointer
		la $a2, 0($t6)
		
		#jal SetArrayToZeros
		
		# get frequencies of letters at each position for each congruence to Keysize
		# then get Key based on Keysize and most common letter guessed
		li $t8, 0 # iterator for Keysize (from 0 to Keysize-1)
		jal GetFrequenciesAndLetters
		
		la $t2, ARRAY_FREQ # reset adress of $t2
		la $a1, 0($t0) # reset text pointer
		
		# add null-terminating condition
		sb $zero, 0($a2)
		# reset pointer
		la $a2, 0($t6)
		
		
		# pop $ra from stack
		lw $ra, 0($sp) # store current $ra in stack
		addi $sp, $sp, 4 # move stack pointer to original position
		
		
		jr $ra

CreateSpace:	
		sb $zero, 0($a2)
		addi $a2, $a2, 1 # iterate through the Key
		
		# check if we are done
		beq $t3, $a0, Done
		# increment iterator
		addi $t3, $t3, 1
		



SetArrayToZeros:
		# if the iterator is >= 27, Done
		# otherwise keep iterating
		sltiu $t7, $t3, 27
		beq $t7, $zero, Done
		
		
		sw $zero, 0($t1) # set to 0
		
		# iteration process:
		addi $t1, $t1, 4 # iterate through the Array
		addi $t3, $t3, 1 # increment the iterator
		
		j SetArrayToZeros


		
GetFrequenciesAndLetters:
		# push $ra on stack
		addi $sp, $sp, -4 # move stack pointer
		sw $ra, 0($sp) # store current $ra in stack
		
		
		li $t3, 1 # iterator from 1 to 26
		la $t1, ARRAY_FREQ # to iterate through the Array
		jal SetArrayToZeros
		
		
		la $t2, ARRAY_FREQ # reset adress of $t2
		la $a1, 0($t0) # reset text pointer
		
		lb $t3, ($a1) # load first char of text
		# shift by the amount of Keysize Iterator (So that we start on the right char)
		li $t4, 0
		jal ShiftText
		# gets frequencies for the ith congruence modulo Keysize
		jal GetFreqCongruence
		
		# guess letter based on most common letter and frequencies
		jal FindLetter
		
		
		
		# pop $ra from stack
		lw $ra, 0($sp) # store current $ra in stack
		addi $sp, $sp, 4 # move stack pointer to original position
		
		# if keysize iterator < Keysize, jump to GetFrequenciesAndLetters again
		# otherwise, we are done 
		addi $t8, $t8, 1 # increase Keysize Iterator (since we started at 0)
		sltu $t7, $t8, $a0
		beq $t7, $zero, Done
		j GetFrequenciesAndLetters

ShiftText:
		# if the sub iterator is equal to the general iterator, we are done
		# otherwise, we shift by 1 and increment the sub iterator
		beq $t4, $t8, Done
		
		addi $a1, $a1, 1 # increment text pointer
		lb $t3, ($a1) # load next char of text
		beq $t3, $zero, Done # exit condition for intermediate char, so that we don't skip the NULL
		
		addi $t4, $t4, 1 # increment sub iterator
		
		
		# iterate
		j ShiftText




GetFreqCongruence:

		beq $t3, $zero, Done # exit condition
		
		# check if it is a letter
		sltiu $t7, $t3, 65
		sltiu $t9, $t3, 91
		ori $t9, $t9, 0xFFFFFFFE # replace everything by one's except LSB
		nor $t9, $t9, $zero # not
		or $t9, $t7, $t9
		# if not, skip
		li $t4, 0 # reset sub iterator for Keysize (Not the general Keysize Iterator, another one)
		bne $t9, $zero, SkipGetFreq	
		
		# get index of array for the corresponding letter
		addi $t1, $t3, -65 # A becomes 0, B becomes 1, ... , Z becomes 25
		add $t1, $t1, $t1 # (*2)
		add $t1, $t1, $t1 # (*2) # A becomes 0, B becomes 4, ... , Z becomes 100
		
		# get adress of index
		add $t1, $t2, $t1 # recall $t2 stores the adress of ARRAY_FREQ
		
		# load value at index, increment, and store the new value
		lw $t9, 0($t1)
		addi $t9, $t9, 1
		sw $t9, 0($t1)
		
		
		# push $ra on stack
		addi $sp, $sp, -4 # move stack pointer
		sw $ra, 0($sp) # store current $ra in stack
		
		
		# iteration process:
		li $t4, 0 # reset sub iterator for Keysize (Not the general Keysize Iterator, another one)
		jal IterationForKeySize
		
		
		# pop $ra from stack
		lw $ra, 0($sp) # store current $ra in stack
		addi $sp, $sp, 4 # move stack pointer to original position
		
		j GetFreqCongruence
		
IterationForKeySize:	
		# check if Keysize Iterator is equal to Keysize
		#if it is, we are done looping
		beq $t4, $a0, Done	
		
		addi $a1, $a1, 1 # increment text pointer
		lb $t3, ($a1) # load next char of text
		beq $t3, $zero, Done # exit condition for intermediate char, so that we don't skip the NULL
		
		addi $t4, $t4, 1 # increment sub Iterator
		
		j IterationForKeySize

SkipGetFreq:
		#addi $a1, $a1, 1 # increment text pointer
		#lb $t3, ($a1) # load next char of text
		#j GetFreqCongruence	
		
		
		# check if Keysize Iterator is equal to Keysize
		#if it is, we are done looping
		beq $t4, $a0, GetFreqCongruence	
		
		addi $a1, $a1, 1 # increment text pointer
		lb $t3, ($a1) # load next char of text
		beq $t3, $zero, Done # exit condition for intermediate char, so that we don't skip the NULL
		
		addi $t4, $t4, 1 # increment sub Iterator
		
		j SkipGetFreq
		
		
FindLetter:	
		# push $ra on stack
		addi $sp, $sp, -4 # move stack pointer
		sw $ra, 0($sp) # store current $ra in stack
		
		# procedure that stores most common letter into $a2, at index Keysize Iterator
		la $t1, ARRAY_FREQ # to iterate
		li $t4, 0 # default highest frequency
		li $t3, 1 # iterator from 1 to 26
		jal StoreLetter
				
		# pop $ra from stack
		lw $ra, 0($sp) # get current $ra from stack
		addi $sp, $sp, 4 # move stack pointer to original position
		
		# to get the corresponding Key, we subtract the most common letter to the one with the highest freq
		lb $t7, 0($a2) # get letter (only works if we are already at the right index)
		subu $t7, $t7, $a3
		addiu $t7, $t7, 65
		
		
		# if result is smaller than ASCII of A, add 26
		sltiu $t9, $t7, 65
		bne $t9, $zero, ModuloForFind
		
		j FindLetterBis

FindLetterBis:	
		sb $t7, 0($a2) # replace value in $a2
		
		addi $a2, $a2, 1 # prepare for next letter
		
		jr $ra
	
ModuloForFind:
		# remove 26 so that we still have a letter
		addi $t7, $t7, 26
		j FindLetterBis
		
StoreLetter:
		# if the iterator is >= 27, Done
		# otherwise keep iterating
		sltiu $t9, $t3, 27
		beq $t9, $zero, Done

		lw $t9, 0($t1) # get next frequency
		
		# print the array (used for debugging)
		#addu $t7, $zero, $a0
		#lw $a0, 0($t1)
		#li $v0, 1
		#syscall	
		#addu $a0, $zero, $t7
		
		
		addi $t1, $t1, 4 # increment array pointer
		addi $t3, $t3, 1 # increment iterator
		
		# if current frequency in $t4 is < than the one in the array, replace it
		sltu $t7, $t4, $t9 
		bne $t7, $zero, ReplaceLetter
		
		j StoreLetter	

ReplaceLetter:
		# update value of $t4 (which represent "current highest freq")
		add $t4, $t9, $zero
		
		
				
		# print letter replaced, used for debugging
		#addu $t7, $zero, $a0
	
		#lb $a0, 0($a2)
		#li $v0, 11
		#syscall	
		
		#addu $a0, $zero, $t7
		
		
		addi $t7, $t3, 63 # if $t3 = 2, we want letter A = 65 = $t3 + 63, because we already incremented $t3
		# sll $t7, $t7, 24 # keep only least significant byte, so that we can store it into $a2
		sb $t7 0($a2)

		j StoreLetter

Done:
		jr $ra	
		
		
		
		
		
		
		
