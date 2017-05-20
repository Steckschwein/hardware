DEFINES=-DCHAR6X8
OBJS=steckschwein.adapter.o appleiimonitor.o

.PHONY: all clean

all: appleiimonitor.bin

clean:
	rm -f *.bin
	
#%.o: %.asm
#	ca65 -o $@ $<


%.bin: %.asm 
	cl65 $(DEFINES)  -Ln symbols.txt --config monitor.cfg -t none --cpu 65c02 -o $@ $<

loader.bin: appleiimonitor.bin
	acme -v -f plain --cpu 65c02 -o loader.bin loader.a


loader: appleiimonitor.bin loader.bin

romtest: loader
	../transfer.py loader.bin -s 0x0400
