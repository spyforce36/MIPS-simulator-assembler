	add $sp, $zero, $imm, 1			# set $sp = 1
	sll $sp, $sp, $imm, 11			# set $sp = 1 << 11 = 2048
	add $t0, $zero, $imm, 6			# set $t0 = 6
	out $imm, $t0, $zero, L2		# set irqhandler as L2
	add $t0, $zero, $imm, 1			# set $t0 = 1
	out $t0, $zero, $imm, 0			# enable irq0
	add $t0, $zero, $imm, 1023		# set $t0 = 1023
	out $t0, $zero, $imm, 13		# write to timermax
	add $t0, $zero, $imm, 1			# set $t0 = 1
	out $t0, $zero, $imm, 11		# write to timerenable
L1:
	lw $a0, $zero, $imm, 256		# $a0 = mem[256]
	lw $a1, $zero, $imm, 257		# $a1 = mem[257]
	bne $imm, $a0, $a1, L1			# jump to L1 if mem[256] != mem[257]
	halt $zero, $zero, $zero, 0		# halt
L2:
	in $s0, $zero, $imm, 9			# read leds register into $s0
	sll $s0, $s0, $imm, 1			# left shift led pattern to the left
	or $s0, $s0, $imm, 1			# lit up the rightmost led
	out $s0, $zero, $imm, 9			# write the new led pattern
	add $s0, $zero, $imm, 255		# set $s0 = 255
	out $s0, $zero, $imm, 21		# write to monitordata
	add $s0, $zero, $imm, 1			# set $s0 = 1
	out $s0, $zero, $imm, 22		# write to monitorcmd
	in $s0, $zero, $imm, 20			# read monitoraddr register into $s0
	add $s0, $s0, $imm, 257			# $s0 = $s0 + 257
	out $s0, $zero, $imm, 20		# set monitoraddr
	lw $s0, $zero, $imm,256			# $s0 = mem[256]
	add $s0, $s0, $imm, 1			# $s0 = $s0 + 1
	sw $s0, $zero, $imm, 256		# mem[256] = $s0
	out $zero, $zero, $imm, 3		# clear irq0 status
	reti $zero, $zero, $zero, 0		# return from interrupt
	.word 257 7
