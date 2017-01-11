OBJS=bios.o charset_8x8.o charset_6x8.o uart.o via.o spi.o out.o vdp.o sdcard.o fat32.o nvram.o
LDFLAGS=--config bios.cfg -m map.txt
.PHONY: all clean
all: version.inc bios.bin 

.PHONY: clean
clean:
	rm -f *.o *.bin version.inc

%.o: %.asm
	ca65 --target none $<



bios.bin: $(OBJS) bios.inc version.inc
	ld65 $(LDFLAGS) $(OBJS) -Ln symbols.txt -o bios.bin
	cat symbols.txt | sed "s/al 0[0-9]//g" | awk -F' ' '{print $$2" = $$"$$1}'| sed -e "s/^\.//g" > bios_call.inc

version.inc:
	echo -n ".byte \"r`hg log -l1 | grep changeset | cut -d ':' -f2 | tr -d ' '`\"" > version.inc


loader.bin: bios.bin
	cl65 --target none --config loader.cfg loader.asm -o loader.bin

transfer: loader.bin
	../transfer.py -s 0x0300 loader.bin
