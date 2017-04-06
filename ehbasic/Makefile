CPU=65c02
OBJ=steck_mon.prg
all: $(OBJ) 
clean:
	rm -f *.prg *.o

%.prg: %.asm basic.asm 
	cl65 --cpu $(CPU) -t none --config ../steckos/kernel/steckos.cfg -o $@ $<

transfer: all
	../transfer.py $(OBJ) 
