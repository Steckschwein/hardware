AVRDEVICE=m8
# 8MHz
CPUSPEED=8000000
FUSES=-U lfuse:w:0xc4:m -U hfuse:w:0xd9:m
#avr-tools
#FUSES=-cUSB -dATmega8 -Fd9c4	#8Mhz

PRG=keyboard

CC=avr-gcc
CFLAGS= -g -Os -Wall -mcall-prologues -mmcu=atmega8  -DF_CPU=$(CPUSPEED) -D__PROG_TYPES_COMPAT__ -std=gnu99

#uncomment to use ATmega USART
#CFLAGS+=-DUSART

#uncomment to use mouse on INT1
#CFLAGS+=-DMOUSE

#uncomment to trigger host system IRQ line when buffer contains > 0 bytes
CFLAGS+=-DUSE_IRQ

#uncomment to enable serial debugging
#CFLAGS+=-DSERIAL_DEBUG

OBJ2HEX = avr-objcopy
OBJDUMP = avr-objdump
LOADER=avrdude -p $(AVRDEVICE)
BURN=-U flash:w:$(PRG).hex -v # -e -D

# avrispmkII usb with avrdude
#
# DEVICE=-c avrispmkII -P usb

# avrispmk2 atprogram (atmel studio 7)
#
#LOADER=atprogram -t avrispmk2 -i ISP
#BURN=program -f $(PRG).hex --flash # -c  # --verify
#DEVICE=-d ATmega8

# -f set fuse bits 16bit value
# -F verify fuse bits
# -E set ext fuse, -G verify ext fuse
# -pf - program flash
# -vf - verify flash
#BURN=-cUSB -dATmega8 -e -if$(PRG).hex -pf -vf

OBJ=kb.o spi.o serial.o main.o
INCLUDE=kb.h
INCLUDE+=spi.h
INCLUDE+=serial.h

#all: $(PRG).elf $(PRG).hex $(PRG).lss $(PRG).eep
all: $(PRG).hex

kb.o: scancodes_de_cp437.h

$(PRG).elf: $(OBJ) $(INCLUDE)
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS)

$(PRG).hex: $(PRG).elf
	$(OBJ2HEX) -j .text -j .data -O ihex $< $@

$(PRG).eep: $(PRG).elf
	$(OBJ2HEX) -j .eeprom --change-section-lma .eeprom=0 -O ihex $< $@

$(PRG).lss: $(PRG).elf
	$(OBJDUMP) -h -S $< > $@

clean:
	rm -f *.hex *.obj *.o *.elf *.eep *.lss

burn: $(PRG).hex
	$(LOADER) $(DEVICE) $(BURN)

fuse:
	$(LOADER) $(DEVICE) $(FUSES)
