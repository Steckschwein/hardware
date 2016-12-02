ASM_INCLUDE=../asminc
LDFLAGS=--config ../kernel/steckos.cfg
#DEBUG=-DDEBUG_SHELL

.PHONY: all clean
all: shell.bin 

.PHONY: clean
clean:
	rm -f *.o *.bin *.map *.txt kernel_jumptable.inc

version.inc:
	echo -n ".byte \"r`hg log -l1 | grep changeset | cut -d ':' -f2 | tr -d ' '`\"" > version.inc


shell.bin: shell.o version.inc
	ld65 $(LDFLAGS) shell.o -o shell.bin

shell: shell.bin
	../../transfer.py -s 0xe000 shell.bin

%.o: %.asm 
	ca65 --target none $(DEBUG) --include-dir $(ASM_INCLUDE)  $<

