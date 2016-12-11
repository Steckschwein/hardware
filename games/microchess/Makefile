OBJ=mchess.prg
all: $(OBJ)
clean:
	rm -f *.prg *.o

%.prg: %.asm
	cl65 -t none --feature labels_without_colons --config ../../steckos/kernel/steckos.cfg -o $@ $<

transfer: all
	../../transfer.py mchess.prg 
