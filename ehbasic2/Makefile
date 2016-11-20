OBJ=min_mon.prg
all: $(OBJ) 
clean:
	rm -f *.prg *.o

%.prg: %.asm basic.asm 
	cl65 -t none  --feature labels_without_colons --config basic.cfg -o $@ $<

transfer: all
	../transfer.py $(OBJ) -s 0xb000
