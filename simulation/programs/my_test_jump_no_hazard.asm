addi r1,r0,#1
addi r2,r0,#31
slli r1,r1,#1
subi r2,r2,#1
nop
bnez r2,#-6
beqz r0,#2
j 92
addi r4,r0,#128
nop
jr r4
jal #164
jalr r31
