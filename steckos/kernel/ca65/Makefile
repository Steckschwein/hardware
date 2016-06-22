OBJS=textui.o t99xx.lib.o rtc.o spi.o uart.o via.o kernel.o
#OBJS=rtc.o spi.o uart.o via.o kernel.o
LDFLAGS=--config steckos.cfg 
.PHONY: all clean
all: kernel.bin loader.bin

.PHONY: clean
clean:
	rm -f *.o *.bin 

%.o: %.asm
	ca65 --target none $<

kernel.bin: $(OBJS) 
	ld65 $(LDFLAGS) $(OBJS) -m kernel.map -o kernel.bin 


loader.bin: kernel.bin
	cl65 --target none -m loader.map --config steckos.cfg loader.asm -o loader.bin

transfer: loader.bin
	../../../transfer.py -s 0x1000 loader.bin
