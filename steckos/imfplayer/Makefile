OBJS=imf.o ym3812.o
TARGET=imf.prg
ASM_INCLUDE=--include-dir ../kernel --include-dir ../asminc


%.prg: $(OBJS)
	cl65 --target none  --config ../kernel/steckosapp.cfg -o $@ $(OBJS)

%.o: %.asm
	ca65 $(ASM_INCLUDE) -o $@ $<

all: $(TARGET) 

clean:
	rm -f $(TARGET) $(OBJS)

imfplayer: $(TARGET)
	../../transfer.py $(TARGET)    
