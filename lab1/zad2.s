.data
	WRITE = 1
	EXIT = 60

	STDOUT = 1

.bss
	.lcomm output, 19

.text
	.globl _start
	_start:
		popq %r11
		cmp $4, %r11
		jne exit_program

		movq %rsp, %rax
		movq 8(%rax), %r8
		movq 16(%rax), %r9
		movq 24(%rax), %r10

		movq %r8, %rdi
		movq %r9, %rsi
		subq %r8, %rsi
		dec %rsi
		call _ascii_to_uint
		movq %rax, %r8

		movq %r9, %rdi
		movq %r10, %rsi
		subq %r9, %rsi
		dec %rsi
		call _ascii_to_uint
		movq %rax, %r9

		movq $0, %rbx
		movb (%r10), %bl
		cmp $100, %rbx
		je addition
		cmp $111, %rbx
		je subtraction
		cmp $109, %rbx
		je multiplication
		cmp $120, %rbx
		je division

		addition:
			addq %r8, %rax
			jmp print_result
		subtraction:
			movq %r8, %rax
			subq %r9, %rax
			jmp print_result
		multiplication:
			mulq %r8
			jmp print_result
		division:
			movq %r8, %rax
			movq $0, %rdx
			divq %r9
			jmp print_result

		jmp exit_program

		print_result:
		movq $output, %rdi
		call _uint_to_ascii

		movq $WRITE, %rax
		movq %rsi, %rdx
		movq $STDOUT, %rdi
		movq $output, %rsi
		syscall

		exit_program:
		movq $EXIT, %rax
		movq $0, %rdi
		syscall

	#input: rdi - adres pierwszego znaku
	#input: rsi - ilość znaków
	#output: rax - liczba dwójkowa
	_ascii_to_uint:
		movq $0, %rcx
		movq $0, %rax
		movq $10, %r11
		
		movq $0, %rbx
		rhorner_loop:
			mulq %r11
			movb (%rdi, %rbx, 1), %cl
			subb $48, %cl
			addq %rcx, %rax

			inc %rbx
			cmp %rbx, %rsi
			jne rhorner_loop
	ret

	#input: rdi - adres bufora
	#intput: rax - liczba dwójkowa
	#output: rsi - ilość znaków
	_uint_to_ascii:
		movq $0, %rsi
		movq $10, %r11
		
		horner_loop:
			movq $0, %rdx
			divq %r11
			addq $48, %rdx
			pushq %rdx
			inc %rsi

			cmp $0, %rax
			jne horner_loop

		movq $0, %rbx
		output_loop:
			popq %rcx
			movb %cl, (%rdi, %rbx, 1)

			inc %rbx
			cmp %rbx, %rsi
			jne output_loop
		movb $10, (%rdi, %rbx, 1)
		inc %rsi #dodanie znaku newline na koniec bufora i zwiększenie ilości znaków w rsi
	ret
			
			
			
			
