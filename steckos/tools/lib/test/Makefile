CA65FLAGS=--include-dir ../../../asminc --include-dir ../../../kernel
LIBS=../toollib.a ../../../lib/steckschwein-kernel.lib
LDFLAGS=--config ../../../steckos-c-app.cfg $(LIBS)
OBJS=test_hexout.o

.PHONY: all clean


all: test_hexout.prg

clean:
	rm -f *.o toollib.a

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)
	
%.prg: %.o $(LIBS)
	ld65 $(LDFLAGS) $< $(LIBS) -o $@