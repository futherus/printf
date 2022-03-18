ASM	:= startup.s printf.s
SRC	:= main.cpp
OBJ 	:= $(patsubst %.s,%.o,$(ASM)) $(patsubst %.cpp,%.o,$(SRC))
BIN 	:= out

FLAGS   := -g -f elf64

all:	build run

run:
	./$(BIN)

build:	$(OBJ)
	ld $(OBJ) -o $(BIN)

%.o: %.s
	nasm $(FLAGS) $< -o $@

%.o: %.cpp
	gcc -c $< -o $@

clean:
	rm $(BIN) $(OBJ)
