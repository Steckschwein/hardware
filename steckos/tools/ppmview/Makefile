DEFINES=
CA65FLAGS=--include-dir ../../asminc --include-dir ../../kernel
LDFLAGS=--config ../../steckos-c-app.cfg $(DEFINES)
LIBS=../lib/toollib.a ../../lib/steckschwein-kernel.lib

.PHONY: all clean


all: ppmview.prg
	(cd test; make)
		
clean:
	rm -f *.prg *.o
	(cd test; make clean)

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.prg: %.main.o %.o $(LIBS)
	ld65 $(LDFLAGS) ppmview.o ppmview.main.o $(LIBS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@ 
	
%: %.prg
	../../transfer.py $< -s 0x1000
