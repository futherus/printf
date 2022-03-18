
global _start

extern main

_start:
        call main

        mov rax, 0x3C
        xor rdi, rdi
        syscall
