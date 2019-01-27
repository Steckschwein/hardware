CAFLAGS=--include-dir ../asminc --include-dir ../kernel
LDFLAGS=--config ../kernel/steckosapp.cfg --lib ../tools/lib/toollib.a
DEBUG=-DDEBUG

.PHONY: all clean
all: version.inc shell.prg

.PHONY: clean
clean:
	rm -f *.o *.bin *.map *.txt version.inc

version.inc:
	echo -n ".byte \"r`hg log -l1 | grep changeset | cut -d ':' -f2 | tr -d ' '`\"" > version.inc

shell.prg: version.inc shell.o
	ld65 shell.o $(LDFLAGS) -o shell.prg

shell: shell.prg
	../../transfer.py -s 0xd800 shell.prg

%.o: %.asm
	ca65 --target none $(DEBUG) $(CAFLAGS)  $<
