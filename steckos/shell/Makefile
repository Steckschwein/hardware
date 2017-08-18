CPU=65c02
ASM_INCLUDE=../asminc
LDFLAGS=--config ../kernel/steckos.cfg
DEBUG=-DDEBUG

.PHONY: all clean
all: version.inc shell.bin 

.PHONY: clean
clean:
	rm -f *.o *.bin *.map *.txt version.inc

version.inc:
	echo -n ".byte \"r`hg log -l1 | grep changeset | cut -d ':' -f2 | tr -d ' '`\"" > version.inc

shell.bin: version.inc shell.o
	ld65 $(LDFLAGS) shell.o -o shell.bin

shell: shell.bin
	../../transfer.py -s 0xe000 shell.bin

%.o: %.asm 
	ca65 --cpu $(CPU) --target none $(DEBUG) --include-dir $(ASM_INCLUDE)  $<

