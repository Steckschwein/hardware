CA65FLAGS=--cpu 65c02 --include-dir ../../../asmunit --include-dir ../../asminc --include-dir ../kernel --include-dir ../
LDFLAGS=--config ../steckosapp.cfg

.PHONY: all clean

all: matcher.test.prg

.PHONY: clean
clean:
	rm -f *.o *.prg *.map *.txt

%.o: %.asm ../matcher.asm
	ca65 -t none $(DEBUG) $(CA65FLAGS) -o $@ $(@:.o=.asm)
	
%.prg: %.o
	ld65 $(LDFLAGS) matcher.test.o -o matcher.test.prg

test.longrun: longrun.test.prg
	../../../transfer.py longrun.test.prg
	
matcher.test: matcher.test.prg
	../../../transfer.py matcher.test.prg