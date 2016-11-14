OBJ=steck_mon.prg
all: $(OBJ) 
clean:
	rm -f *.prg *.o

%.prg: %.asm basic.asm 
	cl65 -t none --config ../steckos/kernel/steckos.cfg -o $@ $<

transfer: all
	../transfer.py $(OBJ) 
