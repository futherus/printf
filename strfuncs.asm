

;%define DEBUG


;================================================
%ifdef DEBUG		;DEBUG
;================================================

section .text
global _start		; predefined entry point name for ld

_start:

;------------------------------------------------
%if 0 			;STRCHR_TEST	
	mov rdi, Msg
	mov al, 'H'
	call _strchr
	mov rbx, rdi

	mov byte [Var], '0'
	jnz .nfind
	inc byte [Var]
	
.nfind:	mov rax, 0x01	;write64(rdi, rsi, rdx) ... r10, r8, r9
	mov rdi, 1	;stdout
	mov rsi, Var
	mov rdx, 1 	;string size
	syscall

section .data
Msg:	db "ForStrchr"
Var:	db 11
section .text

%endif			;STRCHR_TEST
;------------------------------------------------

;------------------------------------------------
%if 0 			;STRNCPY_TEST
	mov rsi, Msg 	;src buffer
	mov rdi, Buf	;dst buffer
	mov rcx, 
	call _strncpy

	mov rax, 0x01	;write64(rdi, rsi, rdx) ... r10, r8, r9
	mov rdi, 1	;stdout
	mov rsi, Buf
	mov rdx, Buf_len
	syscall

section .data
Msg:	db "ForStrncpy"
Buf:	db 20 dup('-') 0xA
Buf_len	equ $ - Buf
section .text

%endif			;STRNCPY_TEST
;------------------------------------------------

;------------------------------------------------
%if 0 			;STRNCMP_TEST
	mov rsi, str1
	mov rdi, str2
	call _strncmp

	jnz .neq
	mov byte [Var], 'E'	;zf=1 -> 1st = 2nd
	jmp .end
	
.neq:	jc  .less
	mov byte [Var], 'G'	;cf=1 -> 1st > 2nd
	jmp .end

.less:	mov byte[Var], 'L'
	
.end:	mov rax, 0x01	;write64(rdi, rsi, rdx) ... r10, r8, r9
	mov rdi, 1	;stdout
	mov rsi, Var
	mov rdx, 1 	;string size
	syscall

section .data
Var:	db '-'
str1:	db 'FirstString', 0x0
str2:	db 'SecondString', 0x0
section .text

%endif			;STRNCMP_TEST
;------------------------------------------------

;------------------------------------------------
%if 0 			;ATOI_TEST

	mov rsi, Numstr
	call _atoi

section .data
Numstr:	db '+2afsdfs', 0x0
Var:	dq '0'
section .text
%endif			;ATOI_TEST
;------------------------------------------------


;------------------------------------------------
;%if 0 			;ITOA_*_TEST

	mov rdx, 10
	mov rbx, 10
	mov rdi, Numstr
	call _itoa

	mov rax, 0x01	;write64(rdi, rsi, rdx) ... r10, r8, r9
	mov rdi, 1	;stdout
	mov rsi, Numstr
	mov rdx, Numstr_len
	syscall

section .data
Numstr:	db 65 dup('.'), '!'
Numstr_len equ $ - Numstr
section .text
;%endif			;ITOA_*_TEST
;------------------------------------------------

	mov rax, 0x3C	;exit64(rdi)
	xor rdi, rdi
	syscall

;================================================
%endif			;ENDDEBUG
;================================================

section .data
XLAT_NUM db '0123456789ABCDEF'
section .text

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;       Returns length of byte null-terminated
;       string
;       ex. 'abc$' -> rcx = 3
;
;entry:	[rsi]   - string address	
;exit:	rcx     - string length
;destr: rcx
;////////////////////////////////////////////////
_strlen:
	mov rcx, 0
        
.loop:
	cmp byte [rsi], 0		;check termination
	je .fin
	inc rsi
	inc rcx
	jmp .loop
        
.fin:
	sub rsi, rcx			;restore si
	ret

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;	Finds first entrance of char in
;	null-terminated string	
;
;entry:	[rdi]	- string address
;	al	- char to search for
;exit:	zf	- 1 if char was found, 0 otherwise
;	[rdi] 	- 1 + address of first char entrance
;	WARNING	- only if char was found
;destr:	di df=0
;////////////////////////////////////////////////
_strchr:

	cld
	
.loop:	cmp byte [rdi], 0	;check termination
	je .end
	scasb			;sets zf=1 if char was found
	jne .loop
	
	ret

.end:	or al, al		;zf = 0
	ret

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;	Copies at most <count> bytes from array
;	[rsi] to array [rdi] including
;	terminating null. If count was reached before
;	null resulting array is not null-terminated.
;
;entry:	[rsi] - src  array address
;	[rdi] - dest array address
;	rcx	- count
;exit:	None
;destr:	rcx rsi rdi df=0
;////////////////////////////////////////////////
_strncpy:

	cld
	jrcxz .ret		;count = 0

.loop:	cmp byte [rsi], 0	;check termination
	movsb			;ds:[si]->es:[di] ;si++ ;di++
	jz .ret			;termination found
	loop .loop

.ret:	ret

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;	Compares lexicographically at most <count> 
;	bytes of two (possibly) null-terminated
;	strings.
;
;entry:	[rsi]	  - first  string
;	[rdi]	  - second string
;	rcx	  - count
;exit:	zf=0 cf=0 - ds:[si] > es:[di]
;	zf=1	  - ds:[si] = es:[di]
;	zf=0 cf=1 - ds:[si] < es:[di]
;destr:	rsi rdi rcx df=0	
;////////////////////////////////////////////////
_strncmp:

	cld

.loop:	cmp byte [rsi], 0	;check termination
	jz .end
	cmpsb
	jnz .ret	
	loop .loop
	
.ret:	ret

.end:	cmpsb			;1=end,2=end->zf=1; 1=end,2!=end->zf=0,cf=0;
	ret


;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;	Converts binary string to number
;
;entry:	[rsi]	- string address
;exit:	rax	- converted number
;destr:	rax, rbx, rcx, rdx, rsi
;////////////////////////////////////////////////
_atoi:

	mov rax, 0
	mov rbx, 0
	mov ecx, 10		;radix

	mov bl, [rsi]		;check sign
	cmp bl, '+'		;
	jz .pos			;
	cmp bl, '-'		;
	jz .neg			;
	push 1			;

.loop:	mov bl, [rsi]
	sub bl, '0'
	cmp bl, 9		;is number
	jg .ret			;
	cmp bl, 0		;
	jl .ret			;

	mul ecx
	add rax, rbx

	inc rsi
	jmp .loop

.ret:	pop rbx			;multiply by sign
	mul ebx			;
	ret

.neg:	push -1
	inc rsi
	jmp .loop

.pos:	push 1
	inc rsi
	jmp .loop

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;	Converts binary number to string
;
;entry: rdx	- number to convert
;	[rdi]	- dst string address
;exit:  [rdi]	- byte after converted number
;destr: rax rcx rdi
;////////////////////////////////////////////////
_itoa_b:

	mov rax, rdx
	mov rcx, 0
.sz:   	inc rcx			;evaluate string size
	shr rax, 1		;
	jnz .sz			;

	push rcx		;save strlen
	
.loop: 	dec rcx
	mov rax, rdx

	shr rax, cl		;1*cl shear
	and rax, 01b	     	;get last bit (bin digit)

	add al, '0'
	stosb

	cmp rcx, 0
	jnz .loop

	pop rax			;rax=strlen
	
	ret

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;	Converts octal number to string
;
;entry: rdx	- number to convert
;	[rdi] 	- dst string address
;exit:  rax	- dst strlen
;	[rdi] 	- byte after converted number
;destr: rax rcx rdi
;////////////////////////////////////////////////
_itoa_o:

	mov rax, rdx
	mov rcx, 0
.sz:   	inc rcx			;evaluate string size
	shr rax, 3		;
	jnz .sz			;

	push rcx		;save strlen

.loop: 	dec rcx
	mov rax, rdx

	shr rax, cl		;3*cl shear
	shr rax, cl 		;
	shr rax, cl 		;
	and rax, 0111b	     	;get last 4 bits (oct digit)

	add al, '0'
	stosb

	cmp rcx, 0
	jnz .loop

	pop rax			;rax=strlen

	ret

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;	Converts hex number to string
;
;entry: rdx	- number to convert
;	[rdi] 	- dst string address
;exit:  rax	- dst strlen
;	[rdi] 	- byte after converted number
;destr: rax rcx rdi
;////////////////////////////////////////////////
_itoa_h:
	push rbx		;save rbx
	
	mov rax, rdx
	mov rcx, 0
.sz:   	inc rcx			;evaluate string size
	shr rax, 4		;
	jnz .sz			;

	push rcx		;save strlen
	lea rbx, XLAT_NUM	;digits translate table
	
.loop: 	dec rcx
	mov rax, rdx

	shr rax, cl		;4*cl shear
	shr rax, cl		;
	shr rax, cl		;
	shr rax, cl		;
	and rax, 01111b	     	;get last 4 bits (hex digit)

	xlat
	stosb

	cmp rcx, 0
	jnz .loop

	pop rax			;rax=strlen
	pop rbx			;restore rbx
	
	ret

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;	Converts decimal number to byte string.
;
;entry:	rdx	- number to convert
;	[rdi]	- dst string address
;	rbx	- radix
;	WARNING:  (64+1)=65 bytes in dest string required
;exit:	rax	- dst strlen
;	[rdi]	- byte after converted number
;destr:	rax rcx rdx rsi rdi df=0
;////////////////////////////////////////////////
_itoa:

	push rdi		;for strlen
	mov rax, rdx
	
	lea rsi, [rdi + 65]	;mov rsi to string_end+1
	test rax, rax		;zf=1 -> negative
	jns .cont		
	neg rax			;convert to positive	
	mov byte [rdi], '-'
	inc rdi			;not to overwrite '-'

.cont:	xor rcx, rcx		;counts converted number length	

.conv: 	xor rdx, rdx		;clean rdx for div
	div rbx			;(rdx,rax)/rbx

	mov dl, XLAT_NUM[rdx]	;translate mod->symbol
	dec rsi			;move along dst string
	inc rcx			;strlen++
	mov [rsi], dl
	
	cmp rax, 0
	jnz .conv
	
	cld			;df=0
	rep movsb		;move converted number to beginning

	pop rcx			;strlen
	mov rax, rdi		;
	sub rax, rcx		;

	ret
