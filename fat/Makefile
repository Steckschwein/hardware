OBJ=rename.prg fat.prg
all: $(OBJ) 
clean:
	rm -f *.prg *.o

%.prg: %.asm
	cl65 -t none --config ../steckos/kernel/steckos.cfg -o $@ $<

transfer: fat.prg
	../transfer.py fat.prg
rename: rename.prg
	../transfer.py rename.prg
