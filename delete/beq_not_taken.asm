## branch file
	.word 20 5 
	lw $s0, $zero, $imm, 20		# 0
	bgt $imm, $s0, $zero, L1	# 1
	add $zero, $zero, $s0, 0	# 2
L1:
	ble $imm, $s0, $zero, END	# 3
	add $s0, $s0, $s0, 0		# 4
	add $zero, $zero, $s0, 0	# 5
END:
 	halt $zero, $zero, $zero, 0	# 6
