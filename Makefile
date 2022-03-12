SRC := printf.asm
OBJ := printf.o
LST := printf.lst
BIN := printf
FLAGS:= -g -f elf64

all: asm link

run:
	./$(BIN)
gdb:
	gdb ./$(BIN)

asm:
	nasm $(FLAGS) $(SRC) -o $(OBJ) -l $(LST)

link:
	ld $(OBJ) -o $(BIN)

clean:
	rm $(OBJ) $(BIN) $(LST)
