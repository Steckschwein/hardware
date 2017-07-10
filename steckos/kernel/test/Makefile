CA65FLAGS=--cpu 65c02 --include-dir ../../../asmunit --include-dir ../../asminc --include-dir ../kernel --include-dir ../
LDFLAGS=--config ../steckos.cfg

.PHONY: all clean

all: matcher.test.prg

.PHONY: clean
clean:
	rm -f *.o *.prg *.map *.txt

%.o: %.asm ../matcher.asm
	ca65 -t none $(DEBUG) $(CA65FLAGS) -o $@ $(@:.o=.asm)
	
%.prg: %.o
	ld65 --config ../steckosapp.cfg matcher.test.o -o matcher.test.prg

test.longrun: longrun.test.prg
	../../../transfer.py longrun.test.prg
	
test.matcher: matcher.test.prg
	../../../transfer.py matcher.test.prg