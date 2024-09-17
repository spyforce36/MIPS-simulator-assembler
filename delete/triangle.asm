.word 0x100 772 # A (row=3, col=4) 3*256+4
.word 0x101 25604 # B (row=100, col=4) 100*256+4
.word 0x102 25800 # C (row=100, col=200) 100*256+200

# The file reads line by line from left to right
# The functions in the end of the file for earning a one less jump.

# Algorithm outline:
# col_start = 4; 
# col_end = 4; 
# col_max = 200;
# row_start = 3;
# row_max = 100;
# for (row=row_start;row<row_max; row++)
#	for (col=col_start; col<=col_end;col++)
# 		update(row,col)
# 	col_end+=ceil(delta_col/delta_row);	
# update(row_max,col_max);

main:
# monitor data=255=IOReg[21]
add $t0, $imm, $zero, 255 # t0=255
out $t0, $imm, $zero, 21 # monitor data=t0=255

# set t0=col_start, t1=row=row_start
add $s0, $imm, $zero, 0x100 # s0 = 0x100
lw $t0, $s0, $zero, 0 # $t0 = A
srl $t1,$t0,$imm,8 # $t1 = row = floor(A/256)
sll $t2, $t1,$imm,8 # $t2 = 256*floor(A/256)
sub $t0, $t0, $t2, 0 # $t0=col_start

# set s0=col_max, s1=row_max
lw $s0, $s0, $imm, 2 # $s0=C 
srl $s1,$s0,$imm,8 # $s1 = row_max = floor(C/256)
sll $s2, $s1,$imm,8 # $s2 = 256*floor(C/256)
sub $s0, $s0, $s2, 0 # $s0=col_max


# summary t0=col_start=$7, t1=row=$8, t2=col=$9, s0=col_max=$10
# s2=col_end=col
# s1=row_max=$11, 

add $s2, $t0, $zero, 0 # col_end=col_start

outer_loop:
add $t2, $t0, $zero, 0 # col=col_start

inner_loop:
jal $ra, $imm, $zero, update_pixel
add $t2, $t2, $imm, 1 # col++

# if col<=col_max then jump to inner_loop
ble $imm, $t2, $s2, inner_loop 

# summary t0=col_start=$7, t1=row=$8, t2=col=$9, s2=col_end=$10
# col_end=col, s0=col_max
# s1=row_max=$11, s2=ceil(delta_y/delta_x)=$12

# for (row=row_start;row<row_max; row++)
#	for (col=col_start; col<=col_end;col++)
# 		update(row,col)
#   delta_row = row_max-row
#   delta_col = col_max-col_end
# 	col_end+=ceil(delta_col/delta_row);	

sub $a0, $s0, $s2, 0 # a0=delta_x=col_max-col_end
sub $a1, $s1, $t1, 0 # a1=delta_y=row_max-row

jal $ra, $imm, $zero, division

add $s2, $s2, $v0, 0 # col_end+=ceil(y/x)

add $t1, $t1, $imm, 1 # row++

# if row<row_max jump to outer_loop
blt $imm, $t1, $s1, outer_loop

end:
	sub $t2, $t2, $imm, 1 # row=row_max,col=col_max
	jal $ra, $imm, $zero, update_pixel
	halt $zero, $zero, $zero, 0


update_pixel:
# t1=row, t2=col
# monitoraddr=row*256+col=IOReg[20]
# monitor data=255=IOReg[21]
# monitorcmd=1=IOReg[22]
sll $a0, $t1,$imm,8 # $a0 = 256*row
add $a0,$a0,$t2, 0 # a0=row*256+col
out $a0, $imm, $zero, 20 # monitoraddr=row*256+col
add $a0,$imm,$zero, 1 # a0=1
out $a0, $imm, $zero, 22 # monitorcmd=1=IOReg[22]
beq $ra, $zero, $zero, 0 # return

division:
# The function changes only $a2, $v0
#
# a0 = y, a1 = x, v0 = round(y/x)
add $v0, $zero, $zero, 0 # row=0
add $a2, $zero, $zero, 0 # $a2=row*x=0
loop_division:
add $v0, $v0, $imm, 1 # row+=1
add $a2, $a2, $a1, 0 # $a2=row*x
# if row*x>=y then end
# if row*x<y then continue
blt $imm, $a2, $a0 , loop_division
# else: row*x>=y, therefore row = ceil(y/x)

# If we want row = round(y/x), we need to subtract 1 if |y-row*x|>|y-(row-1)*x| 
#	iff 0<=row*x-y>y-(row-1)*x>0 iff 2*row*x-x>2*y iff 2*$a2-x>2*y

# 2*$a2-x>2*y
add $a2, $a2, $a2, 0 # $a2*=2;
sub $a2,$a2, $a1, 0 # 2*$a2-x;
add $a0,$a0,$a0,0 # $a0=2y 
# if 2*$a2-x<=2*y jump to end_division
ble $imm, $a2, $a0, end_division
sub $v0, $v0, $imm, 1

end_division:
beq $ra, $zero, $zero, 0 # return






