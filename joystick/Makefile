CPU=65c02
OBJS=fat32.o sdcard.o textui.o t99xx.lib.o rtc.o spi.o uart.o via.o out.o key.o exec.o kernel.o debug.o
ASM_INCLUDE=--include-dir ../steckos/kernel --include-dir ../steckos/asminc
LDFLAGS=--config ../steckos/kernel/steckosapp.cfg ../steckos/tools/lib/toollib.a

.PHONY: all clean

all: joystick.prg
clean:
	rm -f *.prg

%.o: %.asm
	ca65 --cpu $(CPU) --target none $(DEBUG) $(ASM_INCLUDE)  $<

joystick.prg: joystick.o
	ld65  joystick.o $(LDFLAGS) -o joystick.prg

joystick: all
	../transfer.py joystick.prg
