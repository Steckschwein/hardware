ASM_INCLUDE=../../asminc
LIBS=../../lib/steckschwein-gfx.lib

all: nixie.prg

clean:
	rm -f *.prg *.s *.o
	
%.o: %.asm
	ca65 --cpu 65c02 --target none --include-dir $(ASM_INCLUDE) $(@:.o=.asm)

%.prg: %.o $(LIBS)
	ld65 --config ../../kernel/steckosapp.cfg $< $(LIBS) -o $@

nixie: nixie.prg
	../../../transfer.py nixie.prg -s 0x1000