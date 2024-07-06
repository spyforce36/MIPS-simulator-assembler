# opcode, rd, rs, rt, imm
l1: add $t3, $t2, $t1, 0 # $t3 = $t2 + $t1
.word 256 1   # set MEM[256] = 1 
.word 0x100 0x1234A # MEM[0x100] = MEM[256] = 0x1234A
add $t1, $t1, $imm, 2 # $t1 = $t1 + 2
jmp l2
l2: add $t1, $imm, $imm, 2 # $t1 = 2 + 2 = 4
jmp l1
