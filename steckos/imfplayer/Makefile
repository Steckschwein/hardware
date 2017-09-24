OBJS=imf.o ym3812.o
TARGET=imf.prg

%.prg: $(OBJS)
	cl65 --target none  --config ../steckos/kernel/steckosapp.cfg -o $@ $(OBJS)

%.o: %.asm
	ca65 -o $@ $<

all: $(TARGET) 

clean:
	rm -f $(TARGET) $(OBJS)

imfplayer: $(TARGET)
	../transfer.py $(TARGET)    

