.word 0x100 0x200 # choose memory adress for diskbuffer - read.
.word 0x101 0x280 # choose memory adress for diskbuffer - write.

# registers in use in all the program:
# s0, s1, t1, t2

	lw $s0, $zero, $imm, 0x100 #set $s0 to the memory 0X100 
	lw $s1, $zero, $imm, 0x101 #set $s1 to the memory 0X101 

    add $t1, $zero, $zero, 0 # index, set to 0
    add $t2, $zero, $imm, 7 # max value for read

    out $imm, $t2, $zero, L1 # set interrupt return address as L1

    out $imm, $imm, $zero, 1 # enable irq1
	add $t0, $zero, $imm, 2 # use irq2 to fire up the first read/write at the 10'th clock cycle
    out $imm, $zero, $t0, 1 # enable irq2
	
	add $t0, $zero, $imm, 6 # set $t0=6 for irqhandler
    out $imm, $t0, $zero, L2 # set irqhandler as L2
L1:
	beq $imm, $zero,$zero,L1 # stay here till last write
L2:
	in $t0, $imm, $zero, 17 # diskstatus
	bne $imm, $t0, $zero, L1
	
	# read sector t1 to RAM in s0 location
    out $t1, $zero, $imm, 15 # set disksector to current sector for read/write

	# if i>7, write result:
	bgt $imm, $t1, $t2, write_sum
	
	
read_sector:
    out $s0, $zero, $imm, 16 # set $s0 as memory of buffer
	
	add $t2, $zero, $imm, 1 #set $t2 as command for disk(read)
    out $t2, $zero, $imm, 14 #read to disk buffer

# for k=0;k<128;k++	
#	output[k] += input[k];
	add $t0, $zero, $zero, 0 # k=0
	add $s2, $imm, $zero, 128 # s2=128
	
calc_sum_loop:
# registers in use in all the program:
# s0, s1, t1, t2
	lw $a0, $s0, $t0, 0 # a0=input[k]
	lw $a1, $s1, $t0, 0 # a1=output[k]
	beq $imm, $t1, $zero, Do_NOT_add
	add $a0, $a1, $a0, 0 
	Do_NOT_add:
	sw $a0, $s1, $t0, 0
	
	add $t0, $t0, $imm, 1 # k++
	blt $imm, $t0, $s2, calc_sum_loop
	
    end_sum_loop: 
	add $t1, $t1, $imm, 1 # i++

	reti $zero, $zero, $zero, 0 #return from irq call

write_sum:
    out $s1, $zero, $imm, 16 # set $s1 as memory of buffer

    add $t2, $zero, $imm, 2 #set $t2 as command for disk(write)
    out $t2, $zero, $imm, 14 #write to disk sector
	halt $zero, $zero, $zero, 0 # will reach here when done