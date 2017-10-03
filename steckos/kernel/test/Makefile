CA65FLAGS=--cpu 65c02 --include-dir ../../../asmunit --include-dir ../../asminc --include-dir ../
LDFLAGS=--config ../steckosapp.cfg

.PHONY: all clean

all: matcher.test.prg iotest.prg

clean:
	rm -f *.prg *.s *.o

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)
	
%.prg: %.o
	ld65 $< $(LDFLAGS) -o $@

test.longrun: longrun.test.prg
	../../../transfer.py longrun.test.prg
		
%: %.prg
	../../../transfer.py $<