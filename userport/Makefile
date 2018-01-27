CPU=65c02
ASM_INCLUDE=--include-dir ../steckos/kernel --include-dir ../steckos/asminc
LDFLAGS=--config ../steckos/kernel/steckosapp.cfg ../steckos/tools/lib/toollib.a
OBJS=userport.o 
.PHONY: all clean

all: userport.prg
clean:
	rm -f *.prg *.o

%.o: %.asm
	ca65 --cpu $(CPU) --target none $(DEBUG) $(ASM_INCLUDE)  $<

userport.prg: $(OBJS)
	ld65  $(OBJS) $(LDFLAGS) -o userport.prg

userport: all
	../transfer.py userport.prg
