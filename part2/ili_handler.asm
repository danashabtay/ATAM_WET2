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
 
#%rip value (command address) ro %rax
movq 8(%rsp), %rax 	
 
movw (%rax), %ax

xorq %rcx, %rcx
xorq %rdi,%rdi

#compare the first byte in %al of the opcode to 0X0F 
cmp $0x0F, %al
movq $1, %rcx
jne ONE_BYTE

cmp $0x3A, %ah
je ONE_BYTE
cmp $0x38, %ah
je ONE_BYTE

#two byte opcode the last byte is stored in %ah
movb %ah, %dil
movq $2, %rcx
jmp CALL_WHATTODO

ONE_BYTE:
#the byte is stored in %al
movq $1, %rcx
movb %al, %dil
  
CALL_WHATTODO:
call what_to_do
cmp %rax, $0
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

cmp $2, %rcx
jne ONE_BYTE_END
addq $2, (%rsp) 
ONE_BYTE_END:
addq $1, (%rsp)

END:
iretq
