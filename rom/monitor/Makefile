DEFINES=-DCHAR6X8
OBJS=appleiimonitor.o

.PHONY: all clean

all: appleiimonitor.bin

clean:
	rm -f *.bin
	
%.o: %.asm
	ca65 --cpu 65c02 -o $@ $<


appleiimonitor.bin: $(OBJS)
	ld65 $(OBJS) --config monitor.cfg -Ln symbols.txt -o appleiimonitor.bin


loader.bin: appleiimonitor.bin
	acme -v -f plain --cpu 65c02 -o loader.bin loader.a


loader: appleiimonitor.bin loader.bin

romtest: loader
	../transfer.py loader.bin -s 0x0400
