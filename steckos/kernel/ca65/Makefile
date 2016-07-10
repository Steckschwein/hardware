OBJS=fat32.o sdcard.o textui.o t99xx.lib.o rtc.o spi.o uart.o via.o out.o key.o kernel.o
#OBJS=rtc.o spi.o uart.o via.o kernel.o
LDFLAGS=--config steckos.cfg
DEBUG=-D DEBUG

.PHONY: all clean
all: kernel.bin shell.bin loader.bin

.PHONY: clean
clean:
	rm -f *.o *.bin *.map *.txt kernel_jumptable.inc

%.o: %.asm vdp.inc zeropage.inc
	ca65 --target none $(DEBUG) $<

kernel.bin: $(OBJS) 
	ld65 $(LDFLAGS) $(OBJS) -m kernel.map -Ln symbols.txt -o kernel.bin 
	grep krn symbols.txt | awk -F' ' '{print $$3" = $$"$$2}'| sed -e "s/^\.//g" > kernel_jumptable.inc


loader.bin: kernel.bin loader.o
	cl65 --target none --config steckos.cfg loader.asm -o loader.bin

shell.bin: kernel.bin 
	cl65 --target none -m shell.map --config steckos.cfg shell.asm -o shell.bin

transfer: loader.bin
	../../../transfer.py -s 0xe000 shell.bin

test.bin: test.o
	cl65 --target none --config steckos.cfg test.asm -o test.bin

test: test.bin
	../../transfer.py test.bin -s 0x1000
