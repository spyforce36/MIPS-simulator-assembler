# Function prototypes
# int binomial(int n, int k)
# Arguments:
#   a0 - n
#   a1 - k
# Returns:
#   v0 - binomial coefficient

.word 0x100 0xb # n
.word 0x101 0x5 # k
.word 0x102 -3 # result
	
	add $s0,$zero,$imm,0x100	# load address of n to $s
	lw $a0,$s0,$zero,0			# load n to $a0
	lw $a1,$s0,$imm,1			# load k to $a1
	sw $sp, $s0, $imm, 3 # save $sp
	add $sp, $s0, $imm, 3 # update $sp
main:
    # Set up the stack frame
	sw $ra, $sp, $zero, 0 # save $ra
	add $sp, $sp, $imm, 1 # update $sp

    jal $ra, $imm, $zero, binomial                 # Call binomial function
	
	sw $v0, $s0, $imm, 2 # save result

    lw $sp, $s0, $imm, 3			# load k to $a1
	halt $zero, $zero, $zero, 0

# Binomial coefficient calculation
# binomial(n, k):
# if (k == 0 || k == n) return 1;
# else return binomial(n-1, k-1) + binomial(n-1, k);

binomial:
	sw $ra, $sp, $zero, 0 # save $ra
	sw $t0, $sp, $imm, 1 # save $t0
	add $sp, $sp, $imm, 2 # update $sp

    # Base case: if k == 0 or k == n, return 1
    beq $imm, $a1, $zero, base_case    # if k == 0, return 1
    beq $imm, $a0, $a1, base_case      # if k == n, return 1
    
    # Recursive case
    # Prepare arguments for binomial(n-1, k-1)
    add $a0, $a0, $imm, -1            # n = n - 1

    jal $ra, $imm, $zero, binomial # Call binomial(n-1, k)
    add $t0, $v0, $zero, 0  # Save result of binomial(n-1, k)
	
	# we assume $a0, $a1, $t0 did not change during call.
    # Prepare arguments for binomial(n-1, k-1)
	add $a1, $a1, $imm, -1        # k = k - 1
    jal $ra, $imm, $zero, binomial # Call binomial(n-1, k-1)
    
    # Add results of binomial(n-1, k-1) and binomial(n-1, k)
    add $v0, $v0, $t0, 0            # v0 = binomial(n-1, k) + binomial(n-1, k-1)

    # Clean up and return
    beq $imm, $zero, $zero, end_binomial  # Jump to end
    
base_case:
    add $a0, $a0, $imm, -1            # n = n - 1
	add $a1, $a1, $imm, -1        # k = k - 1
    add $v0, $imm ,$zero, 1    # Return 1
    beq $imm, $zero, $zero, end_binomial  # Jump to end
    
end_binomial:
	add $sp, $sp, $imm, -2 # update $sp
	lw $ra, $sp, $zero, 0 # save $ra
	lw $t0, $sp, $imm, 1 # save $t0
    add $a0, $a0, $imm, 1            # restore n
	add $a1, $a1, $imm, 1        #  restore k
    beq $ra, $zero, $zero, 0 # Return from binomial function
