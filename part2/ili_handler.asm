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
movq $1, %rcx
cmpb $0x0F, %bl
jne ONE_BYTE

cmp $0x3A, %bh
je ONE_BYTE
cmp $0x38, %bh
je ONE_BYTE

#two byte opcode the last byte is stored in %bh
movb %bh, %al
movq %rax, %rdi
movq $2, %rcx
jmp CALL_WHATTODO

ONE_BYTE:
#the byte is stored in %al
movq $1, %rcx
movb %bl, %al
movq %rax, %rdi
  
CALL_WHATTODO:
pushq %rcx
call what_to_do
popq %rcx
cmp $0, %rax
jne NOT_ZERO

#if return value is zero:
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
movq %rax, %rdi

cmp $2, %rcx
jne ONE_BYTE_END
addq $2, (%rsp) 
jmp POP_ALL
ONE_BYTE_END:
addq $1, (%rsp)

POP_ALL:
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
