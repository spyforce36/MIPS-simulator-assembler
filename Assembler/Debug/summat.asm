	add $s0,$zero,$imm,0x100	# load address of input matrix 1 to s0
	add $s1,$zero,$imm,0x110	# load address of input matrix 2 to s1
	add $s2,$zero,$imm,0x120	# load address of output matrix to s2
	add $t0,$zero,$zero			# t0 will store the loop index. set to 0
	add $t3,$zero,$imm,16		# t3 will contain the value 16 and help stop the loop
Loop Start:
	lw $t1,$s0,$t0				# load $t0'th cell of first matrix to $t1
	lw $t2,$s1,$t0				# load $t0'th cell of second matrix to $t2
	add $t2,$t1,$t2				# perform sum operation and store it in $t2
	sw $t2,$s2,$t0				# save result in output matrix
	add $t0,$t0,$imm,1			# increase loop index by one
	blt $imm,$t1,$t3,Loop Start # go back to "Loop Start" if the $t0 index did not reach 16 yet
	halt $zero, $zero, $zero, 0	# if the jump does not happen($t0 index did reach 16). stop the program