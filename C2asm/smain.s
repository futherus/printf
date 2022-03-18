
extern printf

global _start

section .text

_start:
        mov rdi, Fmt
        mov rsi, 10
        call printf
        
        mov rax, 0x3C
        xor rdi, rdi
        syscall

section .data
Fmt:
        db "Number is %d", 0xA, 0x0
