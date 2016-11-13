OBJS=strcmp.test.o
LDFLAGS=--config ../bios/bios.cfg
.PHONY: all clean
all: strcmp.test.bin

.PHONY: clean
clean:
	rm -f *.o *.bin 

%.o: %.asm
	ca65 -t none --cpu 65c02 -o $@ $(@:.o=.asm)

strcmp.test.bin: $(OBJS)
	ld65 $(LDFLAGS) $(OBJS) -o strcmp.test.bin
    
test: strcmp.test.bin
	../transfer.py strcmp.test.bin -s 0x1000