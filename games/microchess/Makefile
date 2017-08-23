OBJ=mchess.prg
all: $(OBJ)
clean:
	rm -f *.prg *.o

%.prg: %.asm
	cl65 -t none --cpu 65c02 --feature labels_without_colons --config ../../steckos/kernel/steckosapp.cfg -o $@ $<

transfer: all
	../../transfer.py mchess.prg 
