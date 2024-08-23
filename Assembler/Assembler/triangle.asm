.word 0x100 772 # A (3,4) 3*256+4
.word 0x101 968 # B (3, 200) 3*256+200
.word 0x102 25800 # C (100, 200) 100*256+200

# The functions in the end of the file for earning a one less jump.

# Algorithm outline:
# j_start=4;
# i_max = 100;
# j_max = 200;
	# i_start = 3;
# for (i=i_start;i<i_max; i++)
#	for (j=j_start; j<=j_max;j++)
# 		update(i,j)
# 	j_start+=ceil(y/x);	
# update(i_max,j_max);

main:
# monitor data=255=IOReg[21]
add $t0, $imm, $zero, 255 # t0=255
out $t0, $imm, $zero, 21 # monitor data=t0=255

# set t0=j_start, t1=i
add $s0, $imm, $zero, 0 # s0 = 0x100
lw $t0, $s0, zero, 0 # $t0 = A
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

# for (i=i_start;i<i_max; i++)
#	for (j=j_start; j<=j_max;j++)
# 		update(i,j)
# 	j_start+=ceil(y/x);	
# update(i_max,j_max);

# summary t0=j_start, t1=i, t2=j, s0=j_max
# s1=i_max, s2=ceil(delta_y/delta_x)

outer_loop:
# if i>=i_max jump to end
bge $imm, $t1, $s1, end
add $t2, $t0, $zero, 0 # j=j_start
# if j>j_max then jump to end_inner_loop
bgt $imm, $t2, $s0, end_inner_loop 
jal $ra, $imm, $zero, update_pixel
add $t2, $t2, $imm, 1 
end_inner_loop:
add $t1, $t1, $imm, 1 
add $t0, $t0, $s2, 0 # j_start+=ceil(y/x)

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






