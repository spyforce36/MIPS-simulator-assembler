# opcode, rd, rs, rt, imm
beq $imm, $zero, $zero, l1
l1: add $a3, $t2, $t1, 0 # $t3 = $t2 + $t1
.word 256 101   # set MEM[256] = 0x65
.word 0x101 0x1234A # MEM[0x101] = MEM[257] = 0x1234A
add $t1, $t1, $imm, 2 # $t1 = $t1 + 2
beq $imm, $zero, $zero, l1
l2: add $t1, $imm, $imm, 2 # $t1 = 2 + 2 = 4
beq $imm, $zero, $zero, l2
