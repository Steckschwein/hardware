OBJS=imf.o ym3812.o
TARGET=imf.prg
ASM_INCLUDE=--include-dir ../kernel --include-dir ../asminc
LIBS=../tools/lib/toollib.a

all: $(TARGET)

sndtest.prg: sndtest.o ym3812.o
	cl65 --target none  --config ../kernel/steckosapp.cfg -o $@ sndtest.o ym3812.o $(LIBS)

beep.prg: beep.o ym3812.o
	cl65 --target none  --config ../kernel/steckosapp.cfg -o $@ beep.o ym3812.o $(LIBS)

%.prg: $(OBJS)
	cl65 --target none  --config ../kernel/steckosapp.cfg -o $@ $(OBJS) $(LIBS)

%.o: %.asm
	ca65 $(ASM_INCLUDE) -o $@ $<


clean:
	rm -f $(TARGET) $(OBJS)

imfplayer: $(TARGET)
	../../transfer.py $(TARGET)
