.global	keyMixing, byteSubstitution, shiftRows, cipher

.section	.data
sbox:	.byte	99,124,119,123,-14,107,111,-59,48,1,103,43,-2,-41,-85,118
		.byte	-54,-126,-55,125,-6,89,71,-16,-83,-44,-94,-81,-100,-92,114,-64
		.byte	-73,-3,-109,38,54,63,-9,-52,52,-91,-27,-15,113,-40,49,21
		.byte	4,-57,35,-61,24,-106,5,-102,7,18,-128,-30,-21,39,-78,117
		.byte	9,-125,44,26,27,110,90,-96,82,59,-42,-77,41,-29,47,-124
		.byte	83,-47,0,-19,32,-4,-79,91,106,-53,-66,57,74,76,88,-49
		.byte	-48,-17,-86,-5,67,77,51,-123,69,-7,2,127,80,60,-97,-88
		.byte	81,-93,64,-113,-110,-99,56,-11,-68,-74,-38,33,16,-1,-13,-46
		.byte	-51,12,19,-20,95,-105,68,23,-60,-89,126,61,100,93,25,115
		.byte	96,-127,79,-36,34,42,-112,-120,70,-18,-72,20,-34,94,11,-37
		.byte	-32,50,58,10,73,6,36,92,-62,-45,-84,98,-111,-107,-28,121
		.byte	-25,-56,55,109,-115,-43,78,-87,108,86,-12,-22,101,122,-82,8
		.byte	-70,120,37,46,28,-90,-76,-58,-24,-35,116,31,75,-67,-117,-118
		.byte	112,62,-75,102,72,3,-10,14,97,53,87,-71,-122,-63,29,-98
		.byte	-31,-8,-104,17,105,-39,-114,-108,-101,30,-121,-23,-50,85,40,-33
		.byte	-116,-95,-119,13,-65,-26,66,104,65,-103,45,15,-80,84,-69,22

.section	.text
keyMixing:
# move first 64 bit from input (%rdi) to %rax
	movq (%rdi), %rax
# move first 64 bit from key (%rsi) to %rdx	
	movq (%rsi), %rdx
# xor between first 64 bit - save result in %rdx
	xor %rax, %rdx
#override value in first 64 bit from input
	movq %rdx, (%rdi)
# move last 64 bit from input (%rdi) to %rax
	movq 8(%rdi), %rax
# move last 64 bit from key (%rsi) to %rdx	
	movq 8(%rsi), %rdx
# xor between last 64 bit - save result in %rdx
	xor %rax, %rdx
#save address of start of input+8 byte offset in %rcx
	leaq 8(%rdi), %rcx
#override value in last 64 bit from input
	movq %rdx, (%rcx)
	ret

byteSubstitution:
#save sbox base address to %r11
leaq sbox(%rip), %r11
# %rdi is memory address of input
movq $0, %rax
LOOP_HW2:
	cmp $16,%rax
	je END_HW2
	
	xorq %rcx, %rcx
	
	#get next byte from input
	movb (%rdi,%rax,1), %cl
	
	movq %r11, %rsi 
	
	#calc byte address in sbox
	addq %rcx, %rsi
	
	#move value from sbox to %r9
	movb (%rsi),%r9b
	
	#ovverride value in input byte with the value from sbox
	movb %r9b,(%rdi,%rax,1)
	
	incq %rax	
	jmp LOOP_HW2

END_HW2:
	ret


shiftRows:

movl 4(%rdi), %esi
ror $8, %esi
movl %esi, 4(%rdi)

movl 8(%rdi), %esi
ror $16, %esi
movl %esi, 8(%rdi)

movl 12(%rdi), %esi
ror $24, %esi
movl %esi, 12(%rdi)

ret


cipher:

MAIN_LOOP:
	movq $0, %r8
	#for each block in len blocks:
	cmp $0, %rdx 
	je END_CIPHER
	#perform step a for current block:
	STEP_A:
		pushq %rdi
		pushq %rsi
		pushq %rdx
		pushq %r8
		call keyMixing
		popq %r8
		popq %rdx
		popq %rsi
		popq %rdi
	#for eack block perform 9 iterations:
	BLOCK_9_LOOP:
	cmp $9, %r8
	je STEPS_C_D_E
	#do BS:
		pushq %rdi
		pushq %rsi
		pushq %rdx
		pushq %r8
		call byteSubstitution
		popq %r8
		popq %rdx
		popq %rsi
		popq %rdi
	#do sr:
		pushq %rdi
		pushq %rsi
		pushq %rdx
		pushq %r8
		call shiftRows
		popq %r8
		popq %rdx
		popq %rsi
		popq %rdi
	#do_mc:
		pushq %rdi
		pushq %rsi
		pushq %rdx
		pushq %r8
		call mixColumns
		popq %r8
		popq %rdx
		popq %rsi
		popq %rdi
	#do km:
		pushq %rdi
		pushq %rsi
		pushq %rdx
		pushq %r8
		call keyMixing
		popq %r8
		popq %rdx
		popq %rsi
		popq %rdi
	#finished a loop of 9 loops - incq %r8 and jump:
	incq %r8
	jmp BLOCK_9_LOOP
	
	#perform steps c d e for current block:
	STEPS_C_D_E:
		pushq %rdi
		pushq %rsi
		pushq %rdx
		call byteSubstitution
		popq %rdx
		popq %rsi
		popq %rdi
		
		pushq %rdi
		pushq %rsi
		pushq %rdx
		call shiftRows
		popq %rdx
		popq %rsi
		popq %rdi
		
		pushq %rdi
		pushq %rsi
		pushq %rdx
		call keyMixing
		popq %rdx
		popq %rsi
		popq %rdi
	
	#finished all steps for a single block, move to the next block
		dec %rdx
		lea 16(%rdi), %rdi
		jmp MAIN_LOOP
	
	END_CIPHER:
		ret
