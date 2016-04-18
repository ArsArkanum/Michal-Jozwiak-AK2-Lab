.data
	READ = 0
	WRITE = 1
	EXIT = 60

	STDIN = 0
	STDOUT = 1

	prompt1: .ascii "Podaj pierwsza liczbe: "
	prompt2: .ascii "Podaj druga liczbe: "
	prompt3: .ascii "Wynikiem dodawania jest liczba "

.bss
	.lcomm number, 102 #bufor cyfr dziesietnych
	.lcomm result1, 48 #bufor 1 liczby dwójkowej
	.lcomm result2, 48 #bufor 2 liczby dwójkowej
	.lcomm temp, 48 #bufor przechowujacy tymczasowo wynik dzielenia liczby 48 bajtowej

.text
	.globl _start
	_start:

		movq $WRITE, %rax
		movq $STDOUT, %rdi
		movq $prompt1, %rsi
		movq $23, %rdx
		syscall

		movq $READ, %rax
		movq $STDIN, %rdi
		movq $number, %rsi
		movq $100, %rdx
		syscall

		movq $result1, %r11
		call _ascii_to_uint

		movq $WRITE, %rax
		movq $STDOUT, %rdi
		movq $prompt2, %rsi
		movq $20, %rdx
		syscall

		movq $READ, %rax
		movq $STDIN, %rdi
		movq $number, %rsi
		movq $100, %rdx
		syscall

		movq $result2, %r11
		call _ascii_to_uint

		movq $0, %rax
		movq $6, %rbx
		clc
		add_loop:
			movq result1(, %rax, 8), %rcx
			adcq %rcx, result2(, %rax, 8)
			inc %rax
			jc add_loop
			cmp %rax, %rbx
			jne add_loop

		movq $WRITE, %rax
		movq $STDOUT, %rdi
		movq $prompt3, %rsi
		movq $31, %rdx
		syscall

		call _uint_to_ascii
		movq $101, %r14
		movb $10, number(%r14) #dodanie znaku newline na koniec bufora
		subq %r15, %r14
		addq $number, %r14
		inc %r15

		movq $WRITE, %rax
		movq $STDOUT, %rdi
		movq %r14, %rsi
		movq %r15, %rdx
		syscall

		movq $EXIT, %rax
		movq $0, %rdi
		syscall


	_ascii_to_uint:
		dec %rax
		movq %rax, %r8
		movq $10, %rax

		mov $0, %r9
		loop1:
			movq $0, %rbx
			movq $0, %r10
		loop2:
			mulq (%r11, %r10, 8)
			movq %rax, (%r11, %r10, 8)
			addq %rbx, (%r11, %r10, 8)
			movq %rdx, %rbx
			jnc no_inc #do rbx dodawane jest przeniesienie, ponieważ w tej pętli cmp niszczy flagę przeniesienia
			inc %rbx
			no_inc:
			movq $10, %rax
			inc %r10
			cmp $6, %r10
			jne loop2
		
		subb $48, number(, %r9, 1)
		movq $0, %rcx
		movb number(, %r9, 1), %cl
		addq %rcx, (%r11)
	
		movq $1, %r10
		loop3:
			adcq $0, (%r11, %r10, 8)
			inc %r10
			jc loop3
	
		inc %r9
		cmp %r9, %r8
		jne loop1
	ret

	_uint_to_ascii:
		movq $0, %r15

		loop5:
			movq $1, %r8
		loop6:
			cmp $0, result2(, %r8, 8)
			jne byte48_div
			inc %r8
			cmp $6, %r8
			jne loop6 

		jmp bit64_div
		byte48_div:
		movq result2, %rax
		movq $0, %rdx

		movq $10, %r10
		divq %r10

		inc %rax
		addq %rax, temp
		movq $1, %r8
		loop7:
			adcq $0, temp(, %r8, 8)
			inc %r8
			jc loop7

		subq $10, %rdx
		movq %rdx, result2

		movq $1, %r8
		loop8:
			sbbq $0, result2(, %r8, 8)
			inc %r8
			jc loop8

		jmp loop5

		bit64_div:
		movq result2, %rax
		movq $0, %rdx

		movq $10, %r10
		divq %r10
	
		addq %rax, temp
		movq $1, %r8
		loop9:
			adcq $0, temp(, %r8, 8)
			inc %r8
			jc loop9

		movq $100, %rdi
		subq %r15, %rdi
		addq $48, %rdx
		movb %dl, number(%rdi)
		inc %r15

		movq $0, %r8
		loop10:
			movq temp(, %r8, 8), %r10
			movq %r10, result2(, %r8, 8)
			movq $0, temp(, %r8, 8)
			inc %r8
			cmp $6, %r8
			jne loop10

		cmp $0, %rax
		jne loop5
	ret




