ASM 	:= smain.s
OBJ 	:= $(patsubst %.s,%.o,$(ASM))
BIN 	:= out

LIB	:= /usr/lib/libc.so
DYNLINK	:= /lib64/ld-linux-x86-64.so.2

FLAGS   := -g -f elf64

all:	build run

run:
	./$(BIN)

build:	$(OBJ)
	ld $(LIB) -dynamic-linker $(DYNLINK) $(OBJ) -o $(BIN)

%.o: %.s
	nasm $(FLAGS) $< -o $@

clean:
	rm $(BIN) $(OBJ)
