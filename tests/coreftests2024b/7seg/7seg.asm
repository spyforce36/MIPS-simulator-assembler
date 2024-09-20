	add $zero, $imm, $imm, 1	# try to write 2 (1+1) to $zero -- shouldn't change it
	add $imm, $imm, $imm, 1		# try to write 2 (1+1) to $imm -- shouldn't change it
	add $s0, $zero, $imm, 1		# $s0 = 1
	add $t0, $zero, $imm, 100	$ $t0 = 100
L1:
	out $s0, $zero, $imm, 10	# out $s0 to 7-segment display
	add $s0, $s0, $imm, 1		# increment $s0
	add $s0, $s0, $zero, 0		# add $zero to $s0 (shouldn't change it)
	blt $imm, $s0, $t0, L1		# jump to L1 if $s0 < $t1 (100)
	halt $zero, $zero, $zero, 0	# halt
