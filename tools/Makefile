DEFINES=-DCHAR6x8=1

.PHONY: all clean

all: appleiimonitor.bin

clean:
	rm -f *.bin
	
%.bin: %.a steckschwein.adapter.a ${ACME}/*.a ../bios/bios_call.inc
	acme -v $(DEFINES) -f plain -l $<.labels --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py wozmon.bin 0x1000

loader: appleiimonitor.bin loader.bin 

mon: appleiimonitor.bin
	../transfer.py appleiimonitor.bin -s 0x1000
    
romtest: loader
	../transfer.py loader.bin -s 0x0400
