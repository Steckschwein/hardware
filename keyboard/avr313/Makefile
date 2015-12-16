SERIALDEVICE=$(shell ls -1r /dev/cu.usbmodem* | head -1)
# 2MHz
CPUSPEED=2000000
FUSES=-U lfuse:w:0xc2:m -U hfuse:w:0xd9:m
#FUSES=-cUSB -dATmega8 -fd9c2 -Fd9c2 -EFF -GFF
# 4MHz
#CPUSPEED=4000000
#FUSES=-U lfuse:w:0xc3:m -U hfuse:w:0xd9:m
FUSES=-cUSB -dATmega8 -fd9c3 -Fd9c3 -EFF -GFF
# 8MHz
#CPUSPEED=8000000
#FUSES=-U lfuse:w:0xc4:m -U hfuse:w:0xd9:m
#FUSES=-cUSB -dATmega8 -fd9c4 -Fd9c4 -EFF -GFF
CC=avr-gcc
CFLAGS= -g -Os -Wall -mcall-prologues -mmcu=atmega8 -DF_CPU=$(CPUSPEED) -D__PROG_TYPES_COMPAT__ -std=gnu99
OBJ2HEX=avr-objcopy
OBJDUMP = avr-objdump
LOADER=avrdude
BURN=-c stk500v2 -P $(SERIALDEVICE) -p m8 -b 19200 -U flash:w:$(PRG).hex 
#BURN=-c avrispmkII -p m8 -b 19200 -P usb -U flash:w:$(PRG).hex 
#LOADER=stk500
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

clean :
	rm -f *.hex *.obj *.o *.elf *.eep *.lss

burn : $(PRG).hex
	$(LOADER) $(BURN)
    
fuse : 
	$(LOADER) $(FUSES)



