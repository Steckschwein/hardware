OBJS=mult.o
TARGET=mult.prg

%.prg: $(OBJS)
	cl65 --target none  --config ../steckos/kernel/steckos.cfg -o $@ $(OBJS)

%.o: %.asm
	ca65 -DOUTPUT --cpu 65c02 -o $@ $<

all: $(TARGET) 

clean:
	rm -f $(TARGET) $(OBJS)

tx: $(TARGET)
	../transfer.py $(TARGET)    

