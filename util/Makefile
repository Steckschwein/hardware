OBJS=strcmp.test.o
LDFLAGS=--config ../bios/bios.cfg
.PHONY: all clean
all: strcmp.test.bin

.PHONY: clean
clean:
	rm -f *.o *.bin 

%.o: %.asm
	ca65 --target none $<

strcmp.test.bin: $(OBJS)
	ld65 $(LDFLAGS) $(OBJS) -o strcmp.test.bin
    
test: all
	../transfer.py strcmp.test.bin -s 0x1000