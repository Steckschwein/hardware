OBJS=bios.o charset_8x8.o uart.o via.o
.PHONY: all
all: bios.bin 

.PHONY: clean
clean:
	rm -f *.o *.bin 

%.o: %.asm
	ca65 --target none $<

bios.bin: $(OBJS) bios.inc
	ld65 --config bios.cfg $(OBJS) -o bios.bin


loader.bin: bios.bin
	cl65 --target none --config loader.cfg loader.asm -o loader.bin

transfer: loader.bin
	../../transfer.py -s 0x0300 loader.bin
