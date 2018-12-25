ASM_INCLUDE=../../asminc
LIBS=../../lib/steckschwein-kernel.lib

all: nixie.prg

clean:
	rm -f *.prg *.s *.o
	
%.o: %.asm
	ca65 --cpu 65c02 --target none --include-dir $(ASM_INCLUDE) $(@:.o=.asm)

%.prg: %.o $(LIBS)
	ld65 --config ../../steckos-c-app.cfg $< $(LIBS) -o $@

nixie: nixie.prg
	../../../transfer.py nixie.prg -s 0x1000