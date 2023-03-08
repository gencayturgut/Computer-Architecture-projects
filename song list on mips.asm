		##############################################################
		#Dynamic array
		##############################################################
		#   4 Bytes - Capacity
		#	4 Bytes - Size
		#   4 Bytes - Address of the Elements
		##############################################################

		##############################################################
		#Song
		##############################################################
		#   4 Bytes - Address of the Name (name itself is 64 bytes)
		#   4 Bytes - Duration
		##############################################################


		.data
		space: .asciiz " "
		newLine: .asciiz "\n"
		tab: .asciiz "\t"
		menu: .asciiz "\n● To add a song to the list-> \t\t enter 1\n● To delete a song from the list-> \t enter 2\n● To list all the songs-> \t\t enter 3\n● To exit-> \t\t\t enter 4\n"
		menuWarn: .asciiz "Please enter a valid input!\n"
		name: .asciiz "Enter the name of the song: "
		duration: .asciiz "Enter the duration: "
		name2: .asciiz "Song name: "
		duration2: .asciiz "Song duration: "
		emptyList: .asciiz "List is empty!\n"
		noSong: .asciiz "\nSong not found!\n"
		songAdded: .asciiz "\nSong added.\n"
		songDeleted: .asciiz "\nSong deleted.\n"

		copmStr: .space 64

		sReg: .word 3, 7, 1, 2, 9, 4, 6, 5
		songListAddress: .word 0 #the address of the song list stored here!

		.text 
		main:

			jal initDynamicArray
			sw $v0, songListAddress
			
			la $t0, sReg
			lw $s0, 0($t0)
			lw $s1, 4($t0)
			lw $s2, 8($t0)
			lw $s3, 12($t0)
			lw $s4, 16($t0)
			lw $s5, 20($t0)
			lw $s6, 24($t0)
			lw $s7, 28($t0)

		menuStart:
			la $a0, menu    
			li $v0, 4
			syscall
			li $v0,  5
			syscall
			li $t0, 1
			beq $v0, $t0, addSong
			li $t0, 2
			beq $v0, $t0, deleteSong
			li $t0, 3
			beq $v0, $t0, listSongs
			li $t0, 4
			beq $v0, $t0, terminate
			
			la $a0, menuWarn    
			li $v0, 4
			syscall
			b menuStart
			
		addSong:
			jal createSong
			lw $a0, songListAddress
			move $a1, $v0
			jal putElement
			b menuStart
			
		deleteSong:
			lw $a0, songListAddress
			jal findSong
			lw $a0, songListAddress
			move $a1, $v0
			jal removeElement
			b menuStart
			
		listSongs:
			lw $a0, songListAddress
			jal listElements
			b menuStart
			
		terminate:
			la $a0, newLine		
			li $v0, 4
			syscall
			syscall

			li $v0, 1
			move $a0, $s0
			syscall
			move $a0, $s1
			syscall
			move $a0, $s2
			syscall
			move $a0, $s3
			syscall
			move $a0, $s4
			syscall
			move $a0, $s5
			syscall
			move $a0, $s6
			syscall
			move $a0, $s7
			syscall
			
			li $v0, 10
			syscall


		initDynamicArray:
			li $a0, 12
			li $v0, 9
			syscall
			la $t2, 0($v0)
			li $t0, 2
			li $t1, 0
			sw $t0, 0($t2)
			sw $t1, 4($t2)
			li $a0, 16
			li $v0, 9
			syscall
			move $t1, $v0
			sw $zero 0($t1)
			sw $zero 4($t1)
			sw $zero 8($t1)
			sw $zero 12($t1)
			sw $t1, 8($t2)
			move $v0, $t2
			jr $ra

		putElement:
			lw $t1, 0($a1)
			lw $t7, 4($a1)
			lw $t3, 0($a0)#capacity of the array
			lw $t4, 4($a0)#size of the array
			lw $t5, 8($a0)#address of the elements
			sll $t2, $t4, 3
			add $t2, $t2, $t5
			#add the song to the song array
			sw $t1, 0($t2)
			sw $t7, 4($t2)
			#increase the size of the array
			addi $t4, $t4, 1
			sw $t4, 4($a0)
			#for loop for increasing the capacity
			beq $t4, $t3, end
			jr $ra
			end:
				sll $t3, $t3, 1
				sw $t3, 0($a0)
				sll $t3, $t3, 3
				move $t8, $a0#transferred array into $t8
				move $a0, $t3
				li $v0, 9
				syscall
				move $a0, $t8
				lw $t9, 8($a0)#take address of the songs array
				lw $t5, 4($a0)#take size of the array
				li $t3, 0#counter
				putelementloop:
					sll $t2, $t3, 3
					sll $t1, $t3, 3
					add $t2, $t2, $t9
					add $t1, $t1, $v0
					addi $t3, $t3, 1
					lw $t7, 0($t2)
					lw $t8, 4($t2)
					sw $t7, 0($t1)
					sw $t8, 4($t1)
					bne $t3, $t5, putelementloop
				lw $t4, 0($a0)	
				fillzeros:
					sll $t1, $t3, 3
					add $t1, $t1, $v0
					addi $t3, $t3, 1
					sw $zero, 0($t1)
					sw $zero, 4($t1)
					bne $t3, $t4, fillzeros
			la $t1, 0($v0)
			sw $t1, 8($a0)		
			jr $ra
		removeElement:
			#a1 is the index of the song that we want to remove
			beq $a1, -1,remove_exit 
			lw $t1, 4($a0)#size of the array
			addi $t1, $t1, -1
			sw $t1, 4($a0)#new size of the array
			lw $t2, 8($a0)#address of the elements
			li $t4, 8 #song size
			addi $t3, $a1, -1#for loop counter
			addi $a1, $a1, -1#song index
			# last index removal is our special case
			beq $t1, $a1, lastremove
			removeloop:
				beq $t3, $t1, endremove
				sll $t5, $t3, 3
				add $t5, $t5, $t2
				lw $t6, 8($t5)
				lw $t7, 12($t5)
				sw $t6, 0($t5)
				sw $t7, 4($t5)
				addi $t3, $t3, 1
				bne $t3, $t1, removeloop
			lastremove:
				sll $t5, $t3, 3
				add $t5, $t5, $t2
				sw $zero, 0($t5)
				sw $zero, 4($t5)	
			endremove:
			lw $t2, 0($a0)#capacity of the array
			beq $t2, 2, remove_exit
			srl $t2, $t2, 1
			addi $t2, $t2, -1
			beq $t1, $t2, endremove2
			j remove_exit
			endremove2:
				addi $t2, $t2, 1
				#we need to lower the capacity and store the elements again in our array, first i am going to create a new one with the new capacity
				sll $t4, $t2, 3
				move $t1, $a0
				move $a0, $t4
				li $v0, 9
				syscall
				move $t4, $v0#our new array
				move $a0, $t1#our old array
				sw $t2, 0($a0)#new capacity
				#now i am going to copy the elements to the new array
				li $t3, 0#counter
				lw $t5, 8($a0)#address of the elements
				lw $t1, 4($a0)#size of the array
				copyendremove:
					sll $t6, $t3, 3
					add $t6, $t6, $t5
					sll $t9, $t3, 3
					add $t9, $t9, $t4
					lw $t7, 0($t6)
					lw $t8, 4($t6)
					sw $t7, 0($t9)
					sw $t8, 4($t9)
					addi $t3, $t3, 1
					bne $t3, $t1, copyendremove
					sw $zero, 8($t9)
				la $t1, 0($t4)
				sw $t1, 8($a0)
				remove_exit:
				jr $ra


		listElements:
			#list Elements	
			lw $t0, 4($a0)#size
			beq $t0, $zero, endemptylist
			li $t1, 0
			lw $t2, 8($a0)#address of the elements
			li $v0, 4 #for syscall
			subu $sp, $sp, 8 
   	 		sw   $ra, 0($sp)
			listloop:
				sll $t3, $t1, 3
				add $a0, $t3, $t2
				jal printElement
				addi $t1, $t1, 1
				bne $t1, $t0, listloop
				lw $ra, 0($sp)
				addu $sp, $sp, 8
				jr $ra
			endemptylist:
				la $a0, emptyList
				li $v0, 4
				syscall
				jr $ra
		
		
		compareString:
				#a0 = first string, a1 = second string, a2 = size
				li $t8, 0#byte counter
				compare:
					lb $t5, 0($a0)
					lb $t6, 0($a1)
					bne $t5, $t6, returntofunction
					addi $t8, $t8, 1
					addi $a0, $a0, 1
					addi $a1, $a1, 1
					beq $t8, $a2, songfound
					beq $t5, $t6, compare
				songfound:
					li $v0, 1
					jr $ra
				returntofunction:
					li $v0, 0
					jr $ra
		
			
		printElement:
			sw   $ra, 4($sp)
			jal printSong
			lw   $ra, 4($sp)
			jr $ra


		createSong:
			li $a0, 8
			li $v0, 9
			syscall
			move $t0, $v0
			li $v0, 4
			la $a0, name
			syscall
			li $a0, 64
			li $v0, 9
			syscall
			move $a0, $v0
			li $a1, 64
			li $v0, 8
			syscall
			la $t3, 0($a0)
			li $v0, 4
			la $a0, duration
			syscall
			li $v0, 5
			syscall
			move $t1, $v0
			move $v0, $t0
			sw $t3,0($v0)
			sw $t1, 4($v0)
			jr $ra

		findSong:
			move $v1, $a0
			lw $t0, 4($a0)#size
			lw $t1, 8($a0)#address of the elements
			beq $t0, $zero, findloopend
			li $v0, 4
			la $a0, name
			syscall
			li $a1, 64
			li $v0, 8
			la $a0, copmStr
			syscall
			li $t3, 0#song counter
			li $t4, 8#song size
			add $a2, $a1, -1	
			li $t2 , 1#found
			lw $a1, 8($v1)
			subu $sp, $sp, 4 
			sw   $ra, 0($sp)
			findloop:
				sll $t7, $t3, 3
				add $t7, $t7, $t1
				lw $a1, 0($t7)
				la $a0, copmStr
				jal compareString
				addi $t3, $t3, 1
				beq $t2, $v0, songfoundend
				beq $t3, $t0, songnotfoundend
				beq $zero, $v0, findloop
			songfoundend:
				li $v0, 4
				la $a0, songDeleted
				syscall
				move $v0, $t3
				lw $ra, 0($sp)
				addu $sp, $sp, 4
				jr $ra	
			songnotfoundend:
				la $a0, noSong
				li $v0, 4
				syscall
				li $v0, -1 
				lw $ra, 0($sp)
				addu $sp, $sp, 4
				jr $ra	
			findloopend:
				la $a0, emptyList
				li $v0, 4
				syscall
				li $v0, -1 
				jr $ra	



		printSong:
				lw $t4, 0($a0)#name
				lw $t5, 4($a0)#duration
				la $a0, name2
				syscall
				la $a0, space
				syscall
				move $a0, $t4
				syscall
				la $a0, duration2
				syscall
				la $a0, space
				syscall
				li $v0, 1
				move $a0, $t5
				syscall
				li $v0, 4
				la $a0, newLine
				syscall
			
				jr $ra	

		additionalSubroutines:



