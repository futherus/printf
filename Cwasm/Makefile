ASM 	:= printf.s
SRC	:= main.cpp
OBJ 	:= $(patsubst %.s,%.o,$(ASM)) $(patsubst %.cpp,%.o,$(SRC))
BIN 	:= out

CRT	:= /usr/lib/crt1.o
LIB	:= /usr/lib/libc.so
DYNLINK	:= /lib64/ld-linux-x86-64.so.2

FLAGS   := -g -f elf64

all:	build run

run:
	./$(BIN)

build:	$(OBJ)
	ld $(CRT) $(LIB) -dynamic-linker $(DYNLINK) $(OBJ) -o $(BIN)

%.o: %.s
	nasm $(FLAGS) $< -o $@

%.o: %.cpp
	gcc -c $< -o $@

clean:
	rm $(BIN) $(OBJ)
