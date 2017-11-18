OBJS=sqrt8.o
TARGET=sqrt8.prg

%.prg: $(OBJS)
	cl65 --target none  --config ../steckos/kernel/steckosapp.cfg -o $@ $(OBJS)

%.o: %.asm
	ca65 --cpu 65c02 -o $@ $<

all: $(TARGET) 

clean:
	rm -f $(TARGET) $(OBJS)

tx: $(TARGET)
	../transfer.py $(TARGET)    

