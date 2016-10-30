OBJS=imfplayer.o ym3812.o
TARGET=imfplayer.bin

%.bin: $(OBJS)
	cl65 --target none  --config ../steckos/kernel/steckos.cfg -o $@ $(OBJS)

%.o: %.asm
	ca65 -o $@ $<

all: $(TARGET) 

clean:
	rm -f $(TARGET) $(OBJS)

imfplayer: $(TARGET)
	../transfer.py $(TARGET)    

