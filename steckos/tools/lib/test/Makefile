CA65FLAGS=--include-dir ../../../../asmunit --include-dir ../../../asminc --include-dir ../../../kernel
LIBS=../toollib.a ../../../lib/steckschwein-kernel.lib
LDFLAGS=--config ../../../../asmunit/asmunit.cfg $(LIBS)
OBJS=test_hexout.o

.PHONY: all clean

all: test_hexout.prg

clean:
	rm -f *.prg *.o *.dis toollib.a

%.o: %.asm ../../../../asmunit/*.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)
	
%.prg: %.o $(LIBS)
	ld65 $(LDFLAGS) $< $(LIBS) -o $@

test_%: test_%.prg
	py65mon -m 65c02 -l $@.prg

%.dis: %.prg
	dcc6502 -o 0x1000 -d -n -c $< > $@
