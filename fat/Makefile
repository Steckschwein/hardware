OBJ=fat.prg
all: $(OBJ) 
clean:
	rm -f *.prg *.o

%.prg: %.asm
	cl65 -t none --config ../steckos/kernel/steckos.cfg -o $@ $<

transfer: all
	../transfer.py $(OBJ) 
