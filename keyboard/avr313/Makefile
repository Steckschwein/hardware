SERIALDEVICE=$(shell ls -1r /dev/cu.usbmodem* | head -1)
# 4MHz
CPUSPEED=4000000
FUSES=-U lfuse:w:0xc3:m -U hfuse:w:0xd9:m
# 8MHz
#CPUSPEED=8000000
#FUSES=-U lfuse:w:0xc4:m -U hfuse:w:0xd9:m
CC=avr-gcc
CFLAGS= -g -Os -Wall -mcall-prologues -mmcu=atmega8 -DF_CPU=$(CPUSPEED) -D__PROG_TYPES_COMPAT__ -std=gnu99
OBJ2HEX=avr-objcopy
OBJDUMP = avr-objdump
LOADER=avrdude -c stk500v2 -P $(SERIALDEVICE) -p m8 -b 19200 
#LOADER=avrdude -c avrispmkII -P usb -p m8 -b 19200 
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

clean :
	rm -f *.hex *.obj *.o *.elf *.eep *.lss

burn : $(PRG).hex
	$(LOADER) -U flash:w:$(PRG).hex 

fuse : 
	$(LOADER) $(FUSES)



