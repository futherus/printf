
%include "strfuncs.asm"

%define DEBUG

;================================================
%ifdef DEBUG		;DEBUG
;================================================

global _start

section .text

_start:

	push 1000
	movzx rax, byte [Buf+1]
	push rax
	movzx rax, byte [Buf]
	push rax
	push Buf
	push Msg
	call _printf
	add rsp, 5*8
	
.ret:	mov rax, 0x3C	;exit64(rdi)
	xor rdi, rdi
	syscall	

section .data
Msg:	db '%s%c%c aaa%o%%aaa%%', 0xA, 0x0
Buf:	db 'my', 0x0
Var:	dq 1000
section .text

;===============================================
%endif			;ENDDEBUG
;===============================================

;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;	printf()
;	%%	- '%' escape sequence
;	%c 	- char
;	%s 	- string
;	%d 	- decimal
;	%b 	- binary
;	%o 	- octal
;	%x 	- hex
;entry:	[rsp+2*8]	- format string address
;	[rsp+3*8]	- 1st format argument
;	.
;	.
;	.
;	[rsp+(n+2)*8]	- n-th format argument
;exit:	None
;destr:	rax rbx rcx rdx rsi rdi r8 df
;////////////////////////////////////////////////
_printf:

	push rbp			;prolog
	mov rbp, rsp			;

	mov rbx, 2			;arg index
	mov rsi, [rsp + 2*8]		;format string address
	xor rdx, rdx 			;current offset
	
.look:	cmp byte [rsi + rdx], '%'	;is specifier?
	jnz .symb			;

	mov rax, 0x1			;write() part of string
	mov rdi, 1			;
	syscall				;

	lea rsi, [rsi + rdx + 1]	;skip '%'
	
	cmp byte [rsi], '%'		;is '%%'?
	jnz .spec			;
	mov rdx, 1			;add 2nd '%' to output...
	jmp .look			;...and start from beginning
;\\\\
.spec:	inc rsi				;skip '%*'
	mov r8,  rsi			;save rsi
	inc rbx				;arg_idx++

.c:	cmp byte [rsi-1], 'c'		;is char?
	jnz .s				;
	
	mov rax, 0x1			;write(rdi, rsi, rdx)
	lea rsi, [rbp + rbx*8]		;load char address
	mov rdi, 1 			;stdout
	mov rdx, 1 			;char length
	syscall				;
	jmp .endspec

.s:	cmp byte [rsi-1], 's'		;is string?
	jnz .num			;

	mov rsi, [rbp + rbx*8]		;get string address
	call _strlen			;rsi=string address (const) R:rcx=string length

	mov rax, 0x1			;write() specified string
	mov rdi, 1 			;
	mov rdx, rcx			;rdx=strlen(string arg)
	syscall				;
	jmp .endspec
	
;\\\\\\\\
.num:					;number specifier
	mov rdx, [rbp + rbx*8]		;get number
	mov rdi, .CONVBUF		;set address of convetion buffer

	movzx rax, byte[rsi-1]		;get specifier
	sub rax, 'b'
	jl .endnum			;out-of-range
	cmp rax, 22			;
	jg .endnum			;
	jmp [.jmptbl + rax*8]

.jmptbl:
	dq .b				;0 	(98)
	dq        .endnum		;1
	dq .d				;2 	(100)
	dq 10 dup(.endnum)		;3-12
	dq .o 				;13	(111)
	dq 8  dup(.endnum)		;14-21
	dq .x 				;22	(120)
	
.d:	push rbx			;
	mov rbx, 10			;decimal base
	call _itoa			;
	pop rbx
	jmp .endnum
	
.x:	call _itoa_h			;rax=strlen
	jmp .endnum

.b:	call _itoa_b			;rax=strlen
	jmp .endnum

.o:	call _itoa_o			;rax=strlen
	jmp .endnum

.endnum:
	mov rdx, rax			;strlen
	mov rax, 0x1			;write() converted number
	mov rdi, 1 			;
	mov rsi, .CONVBUF		;
	syscall				;
;////////

.endspec:
	mov rsi, r8			;restore rsi
	xor rdx, rdx			;set initial rdx
	jmp .look
;////

.symb:	inc rdx				;move along format string
	cmp byte [rsi + rdx - 1], 0 	;is termination?
	jnz .look			;
	
	mov rax, 0x1			;write remaining string part
	mov rdi, 1 			;
	syscall				;

	pop rbp				;epilog
	ret				;

section .bss
.CONVBUF:	db 65 dup (?)		;buffer for num2ascii convertion
section .text
