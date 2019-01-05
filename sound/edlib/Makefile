OBJS=edlibply.o
TARGET=edlibply.prg
CAFLAGS=--include-dir ../steckos/kernel --include-dir ../../steckos/asminc --include-dir ../../steckos/kernel
LDFLAGS=--config ../../steckos/steckos-c-app.cfg
LIBS=../../steckos/lib/steckschwein-kernel.lib ../../steckos/tools/lib/toollib.a

.PHONY: all clean

all: $(TARGET)

clean:
	rm -f *.prg *.s *.o

%.prg: %.o $(LIBS)
	ld65 $< $(LDFLAGS) $(LIBS) -o $@

%.o: %.asm
	ca65 $(CAFLAGS) $(@:.o=.asm)

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

%: %.prg
	../../transfer.py $< -s 0x1000