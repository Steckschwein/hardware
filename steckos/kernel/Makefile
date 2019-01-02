CPU=65c02
OBJS=fat32.o sdcard.o textui.o t99xx.lib.o rtc.o spi.o uart.o via.o out.o key.o exec.o util.o matcher.o kernel.o debug.o ansi.o
ASM_INCLUDE=../asminc
LDFLAGS=--config steckos.cfg

# if 9958 is used
DEFINES+=-DV9958
# enable 80 cols
# DEFINES+=-DCOLS80

# enable debug
#DEBUG += -DDEBUG_SDCARD
# debug rtc updates by kernel
#DEBUG += -DDEBUG_RTC
# debug util
#DEBUG += -DDEBUG_UTIL
# debug fat32
#DEBUG += -DDEBUG_FAT32
# dump fat blocks on write
#DEBUG += -DFAT_DUMP_FAT_WRITE
# do not write anything (metadata)
# DEBUG += -DFAT_NOWRITE
#DEBUG += -DV9958
#DEBUG += -DDEBUG_EXECV


# optimize flags
OPT += -DTEXTUI_STROUT
OPT += -DTEXTUI_PRIMM

.PHONY: all clean
all: kernel.bin loader.bin

.PHONY: clean
clean:
	rm -f *.o *.bin *.map *.txt kernel_jumptable.inc version.inc

%.o: %.asm $(ASM_INCLUDE)/vdp.inc zeropage.inc fat32.inc version.inc ../asminc/common.inc
	ca65 --cpu $(CPU) --target none $(DEFINES) $(DEBUG) $(OPT) --include-dir $(ASM_INCLUDE)  $<

version.inc:
	echo -n ".byte \"r`hg log -l1 | grep changeset | cut -d ':' -f2 | tr -d ' '`\"" > version.inc

kernel.bin: version.inc $(OBJS) kernel.inc zeropage.inc debug.inc
	ld65 $(LDFLAGS) $(OBJS) -m kernel.map -Ln symbols.txt -o kernel.bin
	grep krn symbols.txt | sed "s/al 00//" | awk -F' ' '{print $$2" = $$"$$1}'| sed -e "s/^\.//g" > kernel_jumptable.inc

loader.bin: kernel.bin loader.o
	ld65 $(LDFLAGS) loader.o -o loader.bin

	# -m <kernel start adress - $100 (loader)
disas: loader.bin
	dcc6502 -o 0xe700 -m 6394 -d -n -c loader.bin > loader.dis

transfer: loader.bin
	../../transfer.py -s 0x1000 loader.bin

test.bin: test.o
	cl65 --target none --config steckos.cfg test.asm -o test.bin

test:
	(cd test; make test)
