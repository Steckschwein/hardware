TARGET=rx.prg hello.prg

all: $(TARGET)

hello.prg:
	acme -v -f cbm --cpu 65c02 -o hello.prg hello.asm
%.prg: %.asm
	acme -v -f plain --cpu 65c02 -o $@ $<


all: $(TARGET) 

clean:
	rm -f $(TARGET) $(OBJS)

tx: $(TARGET)
	../transfer.py rx.prg 

