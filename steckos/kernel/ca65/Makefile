OBJS=textui.o t99xx.lib.o rtc.o spi.o uart.o via.o out.o key.o kernel.o
#OBJS=rtc.o spi.o uart.o via.o kernel.o
LDFLAGS=--config steckos.cfg 
.PHONY: all clean
all: kernel.bin loader.bin

.PHONY: clean
clean:
	rm -f *.o *.bin *.map *.txt kernel_jumptable.inc

%.o: %.asm
	ca65 --target none $<

kernel.bin: $(OBJS) 
	ld65 $(LDFLAGS) $(OBJS) -m kernel.map -Ln symbols.txt -o kernel.bin 
	grep krn symbols.txt | awk -F' ' '{print $$3" = $$"$$2}'| sed -e "s/^\.//g" > kernel_jumptable.inc


loader.bin: kernel.bin
	cl65 --target none -m loader.map --config steckos.cfg loader.asm -o loader.bin

transfer: loader.bin
	../../../transfer.py -s 0x1000 loader.bin

test.bin: test.o
	cl65 --target none -m loader.map --config steckos.cfg loader.asm -o loader.bin

test: test.bin
	../../transfer.py test.bin -s 0x1000
