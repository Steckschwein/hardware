SERIALDEVICE=$(shell ls -1r /dev/cu.usbmodem* | head -1)
CPUSPEED=4000000
CC=avr-gcc
CFLAGS= -g -Os -Wall -mcall-prologues -mmcu=attiny2313 -DF_CPU=$(CPUSPEED) -D__PROG_TYPES_COMPAT__ -std=gnu99
OBJ2HEX=avr-objcopy
OBJDUMP = avr-objdump
LOADER=avrdude -c stk500v2 -P $(SERIALDEVICE) -p t2313 -b 19200 
PRG=keyboard
OBJ= gpr.o kb.o spi.o main.o 
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

burn : $(PRG).hex
	$(LOADER) -U flash:w:$(PRG).hex 

fuse : 
	$(LOADER) -U lfuse:w:0xe0:m -U hfuse:w:0xdf:m -U efuse:w:0xff:m

