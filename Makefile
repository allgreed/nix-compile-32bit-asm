.DEFAULT_GOAL=main

main.o: main.asm
	nasm -f elf -g main.asm

main: main.o
	gcc -g -m32 main.o -o main

run: main
	./main < inputs/sorted

.PHONY: watch debug
watch:
	ls main.asm input | entr -c make run

debug: main
	gdb -x .gdbinit
