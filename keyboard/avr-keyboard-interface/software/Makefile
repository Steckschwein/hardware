CC=avr-gcc
#CFLAGS= -g -Os -Wall -mcall-prologues -mmcu=attiny2313 -DF_CPU=14745600 -D__PROG_TYPES_COMPAT__
CFLAGS= -g -Os -Wall -mcall-prologues -mmcu=attiny2313 -DF_CPU=8000000 -D__PROG_TYPES_COMPAT__
OBJ2HEX=avr-objcopy
OBJDUMP = avr-objdump
LOADER=avrdude -c stk500v2 -P /dev/cu.usbmodem1a12121 -p t2313 -b 19200 -U flash:w:
PRG=keyboard
OBJ= main.o keyboard.o scancodes.o
all: $(PRG).elf $(PRG).hex $(PRG).lss $(PRG).eep

$(PRG).elf: $(OBJ) 
	$(CC) $(CFLAGS) -o $@ $^ $(LIBS) 

$(PRG).hex: $(PRG).elf 
	$(OBJ2HEX) -j .text -j .data -O ihex $< $@ 

$(PRG).eep: $(PRG).elf 
	$(OBJ2HEX) -j .eeprom --change-section-lma .eeprom=0 -O ihex $< $@ 

$(PRG).lss: $(PRG).elf 
	$(OBJDUMP) -h -S $< > $@

clean :
	rm -f *.hex *.obj *.o *.elf

burn :
	$(LOADER)$(PRG).hex -U lfuse:w:0xe4:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m

