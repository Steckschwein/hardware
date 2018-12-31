LIBS=../../lib/steckschwein-kernel.lib ../../tools/lib/toollib.a
CA65FLAGS=--include-dir ../../asminc --include-dir ../../kernel
LDFLAGS=--config ../../steckos-c-app.cfg $(LIBS)

.PHONY: all clean

all: unrclock.prg 

clean:
	rm -f *.prg *.s *.o

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.prg: %.o ../../lib/steckschwein-kernel.lib
	ld65 $< $(LDFLAGS) -o $@

_%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../../transfer.py $< -s 0x1000
