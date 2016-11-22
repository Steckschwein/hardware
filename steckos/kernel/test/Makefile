OBJS=fat32.o sdcard.o textui.o t99xx.lib.o rtc.o spi.o uart.o via.o out.o key.o exec.o kernel.o
ASM_INCLUDE=../../asminc
LDFLAGS=--config ../steckos.cfg
DEBUG=-DDEBUG
#DEBUG=-DDEBUG_SHELL
#DEBUG+=-DDEBUG_KERNEL

.PHONY: all clean
all: matcher.test.bin

.PHONY: clean
clean:
	rm -f *.o *.bin *.map *.txt

%.test.o: %.test.asm
	ca65 -t none $(DEBUG) --include-dir $(ASM_INCLUDE) --cpu 65c02 -o $@ $(@:.o=.asm)

matcher.test.o: ../matcher.asm ../../../bios/bios_call.inc
	ca65 -t none --cpu 65c02 -o $@ $(@:.o=.asm)
	
matcher.test.bin: matcher.test.o
	ld65 --config ../../../bios/bios.cfg matcher.test.o -o matcher.test.bin

longrun.test.bin: longrun.test.o
	ld65 $(LDFLAGS) longrun.test.o -o longrun.test.bin

test.longrun: longrun.test.bin
	../../../transfer.py longrun.test.bin
	
test.matcher: matcher.test.bin
	../../../transfer.py matcher.test.bin