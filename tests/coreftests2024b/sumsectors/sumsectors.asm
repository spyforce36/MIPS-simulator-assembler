	add $t1, $zero, $imm, IRQ		# $t1 = address of IRQ
	out $t1, $zero, $imm, 6			# set irqhandler as IRQ
	out $imm, $zero, $imm, 1			# enable irq1
	lw $s1, $zero, $imm, 128		# get number of sectors to process from address 128
	lw $a0, $zero, $imm, 129		# get sector number from address 129
	jal $ra, $imm, $zero, F1		# issue read cmd, sector n
	add $a0, $a0, $imm, 1			# increment sector number
	sw $a0, $zero, $imm, 129		# write back to address 129
	jal $ra, $imm, $zero, F2		# wait for disk to be ready
L1:
	lw $a0, $zero, $imm, 129		# get sector number from address 129
	beq $imm, $s1, $a0, L2			# jump to L2 if we already read last sector
	jal $ra, $imm, $zero, F1		# issue read cmd, sector n
	add $a0, $a0, $imm, 1			# increment sector number
	sw $a0, $zero, $imm, 129		# write back to address 129
L2:
	lw $a0, $zero, $imm, 130		# get sector number to sum from address 130
	jal $ra, $imm, $zero, F3		# calc sum of sector n
	add $s0, $s0, $v0, 0			# add to running sum
	add $a0, $a0, $imm, 1			# increment sector address
	sw $a0, $zero, $imm, 130		# write back to address 130
	beq $imm, $s1, $a0, L3			# jump to L3 if we summed last
	jal $ra, $imm, $zero, F2		# wait for disk to be ready
	beq $imm, $zero, $zero, L1		# jump to L1
L3:
	sw $s0, $zero, $imm, 131		# write sum to address 131
	halt $zero, $zero, $zero, 0		# halt
F1:
	out $a0, $zero, $imm, 15		# out sector number to discksector
	and $t2, $a0, $imm, 1			# $t2 = $a0 & 1
	sll $t2, $imm, $t2, 256			# $t2 = 256 for even sectors, 512 for odd
	out $t2, $zero, $imm, 16		# out buffer address $t2 to diskbuffer
	add $t0, $zero, $imm, 14		# set $t0 = 14
	out $imm, $t0, $zero, 1			# initiate read cmd
	beq $ra, $zero, $zero, 0		# and return
F2:
	in $t0, $zero, $imm, 17			# read diskstatus into $t0
	bne $imm, $t0, $zero, F2		# wait for status to become 0
	beq $ra, $zero, $zero, 0		# and return
F3:
	add $v0, $zero, $zero, 0		# zero sum
	add $t0, $zero, $imm, 127		# $t0 = 127, starting to sum from last line to sum in sector
	and $t2, $a0, $imm, 1			# $t2 = $a0 & 1
	sll $t2, $imm, $t2, 256			# $t2 = 256 for even sectors, 512 for odd
L4:
	lw $s2, $t0, $t2, 0			# read current line in sector
	add $v0, $v0, $s2, 0			# add to sum
	sub $t0, $t0, $imm, 1			# decrement line counter
	bge $imm, $t0, $zero,L4			# loop while we still need to sum all lines
	beq $ra, $zero, $zero, 0		# and return
IRQ:
	add $gp, $gp, $imm, 1			# increment $gp
	out $zero, $imm, $zero, 4		# clear irq1 status
	reti $zero, $zero, $zero, 0		# return from interrupt
	.word 128 4				# number of sectors to sum
