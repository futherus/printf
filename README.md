## Compile and link assembly printf in C

Assemble startup.s

        $ nasm -f elf64 -g startup.s -o startup.o

Assemble printf.s

        $ nasm -f elf64 -g printf.s -o printf.o

Compile main.c

        $ gcc -c -g main.c -o main.o

Link object files

        $ ld startup.o printf.o main.o

## Compile and link C dynamic library printf in assembly

Assemble smain.s

        $ nasm -f elf64 -g smain.s -o smain.o

Link smain.o with dynamic library

        $ ld /usr/lib/libc.so -dynamic-linker /lib64/ld-linux-x86-64.so.2 smain.o -o smain

## Compile and link C with assembly

Assemble printf.s

        $ nasm -f elf64 -g printf.s -o printf.o

Compile main.c

        $ gcc -c -g main.c -o main.o

Link object files, crt1.o (standard file with entry point),
  libc.so (C library), ld-<...>.so (dynamic linker)

        $ ld /usr/lib/crt1.o main.o printf.o /usr/lib/libc.so.6 -dynamic-linker \
        /lib64/ld-linux-x86-64.so.2

> Note: dynamic linker name can be found using `gcc`
>
> Create dummy.cpp and compile it with `-v` (verbose) option
>
>        $ gcc -c dummy.cpp -o dummy.o -v
>
> You can redirect output to file using
>
>        $ gcc -c dummy.cpp -o dummy.o -v 2> output.txt
>
>or 
>
>        $ gcc -c dummy.cpp -o dummy.o -v 1> output.txt
>
> In output file you should find `-dynamic-linker` (or `I`) option
