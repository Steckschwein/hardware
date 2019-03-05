SERIALDEVICE=/dev/ttyACM0

# 8MHz
CPUSPEED=8000000
FUSES=-U lfuse:w:0xc4:m -U hfuse:w:0xd9:m
#avr-tools
#FUSES=-cUSB -dATmega8 -Fd9c4	#8Mhz

CC=avr-gcc
CFLAGS= -g -Os -Wall -mcall-prologues -mmcu=atmega8  -DF_CPU=$(CPUSPEED) -D__PROG_TYPES_COMPAT__ -std=gnu99

#uncomment to use ATmega USART 
#CFLAGS+=-DUSART

#uncomment to use mouse on INT1
CFLAGS+=-DMOUSE

#uncomment to trigger host system IRQ line at every keytroke
#CFLAGS+=-DUSE_IRQ

OBJ2HEX=avr-objcopy
OBJDUMP = avr-objdump
LOADER=avrdude -c stk500v2 -P $(SERIALDEVICE) -p m8 -b 19200
BURN=-c stk500v2 -P $(SERIALDEVICE) -p m8 -b 19200 -U flash:w:$(PRG).hex 
#BURN=-c avrispmkII -p m8 -b 19200 -P usb -U flash:w:$(PRG).hex 

#LOADER=stk500
# -f set fuse bits 16bit value
# -F verify fuse bits
# -E set ext fuse, -G verify ext fuse
# -pf - program flash
# -vf - verify flash
#BURN=-cUSB -dATmega8 -e -if$(PRG).hex -pf -vf

PRG=keyboard
OBJ=kb.o spi.o main.o 
all: $(PRG).elf $(PRG).hex $(PRG).lss $(PRG).eep

kb.o: scancodes_de.h

$(PRG).elf: $(OBJ) 
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
	$(LOADER) $(BURN)
    
fuse: 
	$(LOADER) $(FUSES)



