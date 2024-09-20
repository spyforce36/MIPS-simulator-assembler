	add $t2, $zero, $imm, L2			# $t2 = address of L2
	out $t2, $zero, $imm, 6				# set irqhandler as L2
	add $t2, $zero, $imm, 1				# $t2 = 1
	out $t2, $zero, $imm, 2				# enable irq2
	sll $a0, $t2, $imm, 10				# $a0 = $t2 << 10 = 1024
L1:
	in $t0, $zero, $imm, 8				# $t0 = clocks counter
	blt $imm, $t0, $a0, L1				# if ($t0 < 1024) goto L1
	add $t0, $zero, $zero, 0			# $t0 = 0
	halt $zero, $zero, $zero, 0			# halt
L2:
	add $t1, $t1, $imm, 1				# increment $t1
	out $zero, $zero, $imm, 5			# clear irq2 status
	reti $zero, $zero, $zero, 0			# return from interrupt
