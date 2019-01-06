TARGET=edlply.prg edlply64.prg
CAFLAGS=--include-dir ../steckos/kernel --include-dir ../../steckos/asminc --include-dir ../../steckos/kernel
LDFLAGS=--config ../../steckos/steckos-c-app.cfg
LIBS=../../steckos/lib/steckschwein-kernel.lib ../../steckos/tools/lib/toollib.a

C64LIBS=$(CC65_HOME)/lib/c64.lib
C64LDFLAGS=--config c64-asm.cfg

.PHONY: all clean

all: $(TARGET)

clean:
	rm -f *.prg *.s *.o

edlply64.prg: edlply64.o edlib.o $(C64LIBS)
	ld65 $< edlib.o $(C64LDFLAGS) $(C64LIBS) -o $@
    
edlply.prg: edlply.o edlib.o $(LIBS)
	ld65 $< edlib.o $(LDFLAGS) $(LIBS) -o $@

%.o: %.asm
	ca65 $(CAFLAGS) $(@:.o=.asm)

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../transfer.py $< -s 0x1000