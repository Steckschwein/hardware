LIBS=../../steckos/lib/steckschwein-kernel.lib ../../steckos/tools/lib/toollib.a
CA65FLAGS=--include-dir ../../steckos/asminc --include-dir ../../steckos/kernel
LDFLAGS=--config ../../steckos/steckos-c-app.cfg $(LIBS)

.PHONY: all clean

all: pong.prg 

clean:
	rm -f *.prg *.s *.o

%.o: %.asm
	ca65 $(CA65FLAGS) $(@:.o=.asm)

%.prg: %.o ../../steckos/lib/steckschwein-kernel.lib
	ld65 $< $(LDFLAGS) -o $@

%: %.prg
	../../transfer.py $< -s 0x1000
