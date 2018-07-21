CA65FLAGS=--include-dir ../../../../asmunit --include-dir ../../../asminc --include-dir ../../../kernel
LIBS=../toollib.a ../../../lib/steckschwein-kernel.lib
LDFLAGS=--config ../../../../asmunit/asmunit.cfg $(LIBS)
OBJS=test_hexout.o

.PHONY: all clean

all: test_hexout.prg

clean:
	rm -f *.prg *.o toollib.a

%.o: %.asm ../../../../asmunit/*.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)
	
%.prg: %.o $(LIBS)
	ld65 $(LDFLAGS) $< $(LIBS) -o $@
	
test_%: test_%.prg
	py65mon -m 65c02 -l $@.prg