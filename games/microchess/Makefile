OBJ=mchess.prg
LIBS=../../steckos/tools/lib/toollib.a
LDFLAGS=--config ../../steckos/kernel/steckosapp.cfg

all: $(OBJ)
clean:
	rm -f *.prg *.o

%.o: %.asm
	ca65 -t none --cpu 65c02 --feature labels_without_colons $(@:.o=.asm)

%.prg: %.o
	ld65 $(LDFLAGS) $< $(LIBS) -o $@


transfer: all
	../../transfer.py mchess.prg
