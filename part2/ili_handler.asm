.globl my_ili_handler

.text
.align 4, 0x90
my_ili_handler:
pushq %rax
pushq %rbx
pushq %rcx
pushq %rdx	
pushq %r8
pushq %r9
pushq %r10
pushq %r11
pushq %r12
pushq %r13
pushq %r14
pushq %r15
pushq %rsi
pushq %rbp
pushq %rsp
 
#%rip value (command address) ro %rbx

xorq %rbx, %rbx
xorq %rcx, %rcx
xorq %rdi,%rdi
xorq %rax, %rax

movq (%rsp), %rbx 	
movq (%rbx), %rbx

#compare the first byte in %bl of the opcode to 0X0F 
cmpb $0x0F, %bl
jne ONE_BYTE

#compare the second byte in %bh of the opcode to 0X3A or 0x38 
cmp $0x3A, %bh
je ONE_BYTE
cmp $0x38, %bh
je ONE_BYTE

#if it's a two byte opcode the last byte is stored in %bh
movb %bh, %al
movq %rax, %rdi
movq $2, %rcx
jmp CALL_WHATTODO

ONE_BYTE:
#the byte is stored in %bl
movq $1, %rcx
movb %bl, %al
movq %rax, %rdi
  
CALL_WHATTODO:
call what_to_do
cmp $0, %rax
jne NOT_ZERO

#if return value is zero call the old handler:
old_handler:
popq %rsp
popq %rbp
popq %rsi
popq %r15
popq %r14
popq %r13
popq %r12
popq %r11
popq %r10
popq %r9
popq %r8
popq %rdx
popq %rcx
popq %rbx
popq %rax

jmp * old_ili_handler
jmp END

#if return value is not zero:
NOT_ZERO:
#put return value in %rdi
movq %rax, %rdi

#move the to the next instruction depends on the opcode size that is saved in %rcx:
cmp $2, %rcx
jne ONE_BYTE_END
addq $2, (%rsp) 
ONE_BYTE_END:
addq $1, (%rsp)

popq %rsp
popq %rbp
popq %rsi
popq %r15
popq %r14
popq %r13
popq %r12
popq %r11
popq %r10
popq %r9
popq %r8
popq %rdx
popq %rcx
popq %rbx
popq %rax

END:
iretq
