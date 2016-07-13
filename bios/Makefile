OBJS=bios.o charset_8x8.o uart.o via.o spi.o out.o vdp.o sdcard.o fat32.o nvram.o
LDFLAGS=--config bios.cfg -m map.txt
.PHONY: all clean
all: bios.bin 

.PHONY: clean
clean:
	rm -f *.o *.bin 

%.o: %.asm
	ca65 --target none $<

bios.bin: $(OBJS) bios.inc
	ld65 $(LDFLAGS) $(OBJS) -Ln symbols.txt -o bios.bin
	cat symbols.txt | awk -F' ' '{print $$3" = $$"$$2}'| sed -e "s/^\.//g" > bios_call.inc


loader.bin: bios.bin
	cl65 --target none --config loader.cfg loader.asm -o loader.bin

transfer: loader.bin
	../transfer.py -s 0x0300 loader.bin
