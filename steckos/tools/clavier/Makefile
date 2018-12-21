CPU=65c02
CC65FLAGS=--include-dir ../../include
CA65FLAGS=--include-dir ../../asminc
LDFLAGS=--config ../../steckos-c-app.cfg ../../lib/steckschwein-kernel.lib ../lib/toollib.a -Dchar_out=0xFFB3

.PHONY: all clean

all: clavier.prg

clean:
	rm -f *.prg *.s *.o
    
%.o: %.c
	cc65 $(CC65FLAGS) -t none --cpu $(CPU) -O $<
	ca65 --cpu $(CPU) $(CA65FLAGS) $(@:.o=.s)

%.prg: %.o ../../lib/steckschwein-kernel.lib
	ld65 $< $(LDFLAGS) -o $@

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../../transfer.py $< -s 0x1000