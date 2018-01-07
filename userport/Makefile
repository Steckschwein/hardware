CPU=65c02
ASM_INCLUDE=--include-dir ../steckos/kernel --include-dir ../steckos/asminc
LDFLAGS=--config ../steckos/kernel/steckosapp.cfg ../steckos/tools/lib/toollib.a

.PHONY: all clean

all: userport.prg
clean:
	rm -f *.prg

%.o: %.asm
	ca65 --cpu $(CPU) --target none $(DEBUG) $(ASM_INCLUDE)  $<

userport.prg: userport.o
	ld65  userport.o $(LDFLAGS) -o userport.prg

userport: all
	../transfer.py userport.prg
