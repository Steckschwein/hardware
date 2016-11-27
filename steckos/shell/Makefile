ASM_INCLUDE=../asminc
LDFLAGS=--config ../kernel/steckos.cfg
#DEBUG=-DDEBUG_SHELL

.PHONY: all clean
all: shell.bin 

.PHONY: clean
clean:
	rm -f *.o *.bin *.map *.txt kernel_jumptable.inc

shell.bin: shell.o
	ld65 $(LDFLAGS) shell.o -o shell.bin

shell: shell.bin
	../../transfer.py -s 0xe000 shell.bin

%.o: %.asm 
	ca65 --target none $(DEBUG) --include-dir $(ASM_INCLUDE)  $<

