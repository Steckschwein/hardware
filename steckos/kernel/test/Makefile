TOOLLIB=../../tools/lib/toollib.a
CA65FLAGS=--cpu 65c02 --target sim65c02 --include-dir ../../../asmunit --include-dir ../../asminc --include-dir ../ --include-dir ../../../asmunit
LDFLAGS=--config ../steckosapp.cfg $(TOOLLIB)


.PHONY: all clean

all: matcher.test.prg iotest.prg test_out.prg

clean:
	rm -f *.prg *.s *.o

%.o: %.asm ../*.inc
	ca65 $(CA65FLAGS) $(@:.o=.asm)
	
%.prg: %.o $(TOOLLIB)
	ld65 $< $(LDFLAGS) -o $@

test.longrun: longrun.test.prg
	../../../transfer.py longrun.test.prg
		
%: %.prg
	../../../transfer.py $<