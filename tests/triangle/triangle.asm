.word 0x100 772 # A (row=3,col=4) 3*256+4
.word 0x101 25604 # B (row=100, col=4) 100*256+4
.word 0x102 25800 # C (row=100, col=200) 100*256+200

# The file reads line by line from left to right
# The functions in the end of the file for earning a one less jump.

# Algorithm outline:
# j_end=4; # col
# i_max = 100;
# j_max = 200;
# i_start = 3; # row
# for (i=i_start;i<i_max; i++)
#	for (j=4; j<=j_end;j++)
# 		update(i,j)
# 	j_end+=ceil(y/x);	
# update(i_max,j_max);

main:
# monitor data=255=IOReg[21]
add $t0, $imm, $zero, 255 # t0=255
out $t0, $imm, $zero, 21 # monitor data=t0=255

# set t0=j_start, t1=i
add $s0, $imm, $zero, 0x100 # s0 = 0x100
lw $t0, $s0, $zero, 0 # $t0 = A
srl $t1,$t0,$imm,8 # $t1 = i = floor(A/256)
sll $t2, $t1,$imm,8 # $t2 = 256*floor(A/256)
sub $t0, $t0, $t2, 0 # $t0=j_start

# set s0=j_max, s1=i_max
lw $s0, $s0, $imm, 2 # $s0=C 
srl $s1,$s0,$imm,8 # $s1 = i_max = floor(C/256)
sll $s2, $s1,$imm,8 # $s2 = 256*floor(C/256)
sub $s0, $s0, $s2, 0 # $s0=j_max

# set s2=ceil(delta_y/delta_x)
sub $a0, $s0, $t0, 0 # a0=delta_y=j_max-j_start
sub $a1, $s1, $t1, 0 # a1=delta_x=i_max-i_start
jal $ra, $imm, $zero, division
add $s2, $v0, $zero, 0

# summary t0=j_start=$7, t1=i=$8, t2=j=$9, s0=j_max=$10
# j_end=j
# s1=i_max=$11, s2=ceil(delta_y/delta_x)=$12

# j_end=4; # col
# for (i=i_start;i<i_max; i++)
#	for (j=4; j<=j_end;j++)
# 		update(i,j)
# 	j_end+=ceil(y/x);	
# update(i_max,j_max);

add $s0, $t0, $zero, 0 # j_end=j_start

outer_loop:
add $t2, $t0, $zero, 0 # j=j_start

inner_loop:
jal $ra, $imm, $zero, update_pixel
add $t2, $t2, $imm, 1 # j++

# if j<=j_max then jump to inner_loop
ble $imm, $t2, $s0, inner_loop 

add $s0, $s0, $s2, 0 # j_start+=ceil(y/x)
add $t1, $t1, $imm, 1 # i++

# if i<i_max jump to outer_loop
blt $imm, $t1, $s1, outer_loop

end:
	sub $t2, $t2, $imm, 1 # i=i_max,j=j_max
	jal $ra, $imm, $zero, update_pixel
	halt $zero, $zero, $zero, 0


update_pixel:
# t1=i, t2=j
# monitoraddr=i*256+j=IOReg[20]
# monitor data=255=IOReg[21]
# monitorcmd=1=IOReg[22]
sll $a0, $t1,$imm,8 # $a0 = 256*i
add $a0,$a0,$t2, 0 # a0=i*256+j
out $a0, $imm, $zero, 20 # monitoraddr=i*256+j
add $a0,$imm,$zero, 1 # a0=1
out $a0, $imm, $zero, 22 # monitorcmd=1=IOReg[22]
beq $ra, $zero, $zero, 0 # return

division:
# The function changes only $s2, $v0
#
# a0 = y, a1 = x, v0 = ceil(y/x)
add $v0, $zero, $zero, 0 # i=0
add $s2, $zero, $zero, 0 # $s2=i*x=0
loop_division:
add $v0, $v0, $imm, 1 # i+=1
add $s2, $s2, $a1, 0 # $s2=i*x
# if i*x>=y then end
# if i*x<y then continue
blt $imm, $s2, $a0 , loop_division
# else: i*x>=y, therefore i = ceil(y/x)
# If we want i = round(y/x), we need to subtract 1 if |y-i*x|>|y-(i-1)*x| 
#	iff 0<=i*x-y>y-(i-1)*x>0 iff 2*i*x-x>2*y iff 2*$s2-x>2*y
#
beq $ra, $zero, $zero, 0 # return






