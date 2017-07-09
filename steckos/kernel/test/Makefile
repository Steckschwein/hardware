CA65FLAGS=--cpu 65c02 --include-dir ../../../asmunit --include-dir ../../asminc --include-dir ../kernel --include-dir ../../../rom/bios
LDFLAGS=--config ../steckos.cfg

.PHONY: all clean

all: matcher.test.prg

.PHONY: clean
clean:
	rm -f *.o *.prg *.map *.txt

%.o: %.asm ../matcher.asm ../../../rom/bios/bios_call.inc
	ca65 -t none $(DEBUG) $(CA65FLAGS) -o $@ $(@:.o=.asm)
	
matcher.test.prg: matcher.test.o
	ld65 --config ../../../rom/bios/bios.cfg matcher.test.o -o matcher.test.prg

longrun.test.prg: longrun.test.o
	ld65 $(LDFLAGS) longrun.test.o -o longrun.test.prg

test.longrun: longrun.test.prg
	../../../transfer.py longrun.test.prg
	
test.matcher: matcher.test.prg
	../../../transfer.py matcher.test.prg