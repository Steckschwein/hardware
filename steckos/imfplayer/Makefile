OBJS=imf.o
TARGET=imf.prg
CA65FLAGS=--include-dir ../kernel --include-dir ../asminc
LIBS=../tools/lib/toollib.a ../lib/steckschwein-kernel.lib

all: $(TARGET)

sndtest.prg: sndtest.o
	cl65 --target none --config ../steckos-c-app.cfg -o $@ sndtest.o ym3812.o $(LIBS)

beep.prg: beep.o
	cl65 --target none --config ../steckos-c-app.cfg -o $@ beep.o ym3812.o $(LIBS)

%.prg: $(OBJS) $(LIBS)
	cl65 --target none --config ../steckos-c-app.cfg -o $@ $(OBJS) $(LIBS)

%.o: %.asm
	ca65 $(CA65FLAGS) -o $@ $<

%.dis: %.prg
	dcc6502 -o 0x0ffe -d -n -c $< > $@

clean:
	rm -f $(TARGET) $(OBJS)

imfplayer: $(TARGET)
	../../transfer.py $(TARGET)
