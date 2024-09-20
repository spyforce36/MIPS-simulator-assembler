	lw $a0, $zero, $imm, 256	# $a0 = mem[256]
	lw $a1, $zero, $imm, 257	# $a1 = mem[256]
	bgt $imm, $a0, $zero, L0	# if ($a0 > 0) goto L0
	lw $a2, $zero, $imm, 258	# $a2 = mem[258]
L0:
	add $t0, $imm, $imm, 1		# $t0 = 1+1 = 2
	sub $t1, $t0, $imm, 5		# $t1 = $t0-5 = 2 - 5 = -3
	sw $t1, $zero, $imm, 259	# mem[259] = $t1
	lw $a3, $zero, $imm, 259	# $a3 = mem[259]
	mul $t2, $t0, $t1, 0		# $t2 = $t0*$t1 = 2 * (-3) = -6
	sub $s0, $zero, $imm, 1		# $s0 = 0 - 1 = -1
	and $s0, $s0, $imm, 3		# $s0 = (-1) & 3 = 3
	or $s1, $s0, $imm, 8		# $s1 = 3 | 8 = 11
	xor $s2, $t0, $imm, 6		# $s2 = $t0 ^ 6 = 2 ^ 6 = 010 ^ 110 = 101 = 5
	sub $t0, $zero, $imm, 1		# $t0 = 0 - 1 = -1
	sll $t0, $t0, $imm, 1		# $t0 = $t0 << 1 = -2
	srl $sp, $t0, $imm, 1		# $sp = $t0 >> 1 (logical shift) = 0x7fffffff
	sra $t1, $t0, $imm, 1		# $t1 = $t0 >> 1 = -1
	beq $imm, $t0, $t1, L1		# if ($t0 == $t1) goto L1
L1:
	bne $imm, $t0, $t1, L2		# a: if ($t0 != $t1) goto L2
L2:
	blt $imm, $t0, $t1, L3		# b: if ($t0 < $t1) goto L3
L3:
	bgt $imm, $t0, $t1, L4		# if ($t0 > $t1) goto L4
	bge $imm, $t0, $t1, L4		# if ($t0 >= $t1) goto L4
	jal $ra, $imm, $zero, L5		# e: call L5
	ble $imm, $t0, $t1, L4		# if ($t0 <= $t1) goto L4
L5:
	add $gp, $zero, $imm, 9		# $gp = 9
L4:
	halt $zero, $zero, $zero, 0	# halt
.word 256 -1
.word 257 0xFFFFF
.word 258 2
.word 259 3
