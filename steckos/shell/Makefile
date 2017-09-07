CPU=65c02
ASM_INCLUDE=../asminc
LDFLAGS=--config ../kernel/steckosapp.cfg
#DEBUG=-DDEBUG

.PHONY: all clean
all: version.inc shell.prg

.PHONY: clean
clean:
	rm -f *.o *.bin *.map *.txt version.inc

version.inc:
	echo -n ".byte \"r`hg log -l1 | grep changeset | cut -d ':' -f2 | tr -d ' '`\"" > version.inc

shell.prg: version.inc shell.o
	ld65 $(LDFLAGS) shell.o -o shell.prg

shell: shell.prg
	../../transfer.py -s 0xd800 shell.prg

%.o: %.asm
	ca65 --cpu $(CPU) --target none $(DEBUG) --include-dir $(ASM_INCLUDE)  $<
