TARGET=appleiimonitor.prg

%.prg: appleiimonitor.asm
	cl65 --cpu 65c02 --target none  --config ../steckos/kernel/steckos.cfg -o $@  appleiimonitor.asm

%.o: %.asm
	ca65 -o $@ $<

all: $(TARGET) 

clean:
	rm -f $(TARGET) $(OBJS)

imfplayer: $(TARGET)
	../transfer.py $(TARGET)    

