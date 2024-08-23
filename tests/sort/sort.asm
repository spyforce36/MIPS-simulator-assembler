#array to be sorted

.word 1024 246
.word 1025 352
.word 1026 27
.word 1027 33
.word 1028 87
.word 1029 2
.word 1030 543
.word 1031 4325
.word 1032 22
.word 1033 34
.word 1034 87
.word 1035 176
.word 1036 22
.word 1037 34
.word 1038 56
.word 1039 44

	add $s0,$zero,$imm,1024		# load address of input array to $s
	add $s1,$zero,$zero,0		# $s1 is the outer loop index
OuterLoop:
	add $s2,$zero,$zero,0		# $s2 is the inner loop index
InnerLoop:
	lw $t0,$s0,$s2,0			# load the array element at $s2 into $t0
	add $t1,$s2,$imm,1			# use t1 to store the index $s2+1
	lw $t2,$s0,$t1,0			# load array element at $t1 into $t2
	ble $imm,$t0,$t2,endif		# if array value at t0 is smaller or equal to that at t2. skip the if. this is used as an if statement
	sw  $t2,$s0,$s2,0			# swap array indexes by sending the registers they were saved in to the other address
	sw $t0,$s0,$t1,0
endif:							# go here on if skip
	add $s2,$s2,$imm,1			# inner loop index ++
	add $t0,$zero,$imm,15		# index for outer loop end(n-1)
	sub $t1,$t0,$s1,0			# index in which inner loop ends
	blt $imm,$s2,$t1,InnerLoop	# go back to start of inner loop if not enough iterations
	add $s1,$s1,$imm,1			# outer loop index ++
	add $t0,$zero,$imm,15		# in case the inner loop did not play set t0 to end index of outer loop
	blt $imm,$s1,$t0,OuterLoop	# go back to start of outer loop if not enough iterations
	halt $zero,$zero,$zero,0	# if this is reached, stop the program