TARGET=rx.prg 

all: $(TARGET)

%.prg: %.asm
	acme -v -f cbm --cpu 65c02 -o $@ $<


all: $(TARGET) 

clean:
	rm -f $(TARGET) $(OBJS)

tx: $(TARGET)
	../transfer.py rx.prg 

