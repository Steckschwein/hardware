DEFINES=-DCHAR6x8=1

.PHONY: all clean

all: appleiimonitor.bin

clean:
	rm -f *.bin
	
%.bin: %.a steckschwein.adapter.a ${ACME}/*.a 
	acme -v $(DEFINES) -f plain -l $<.labels --cpu 65c02 -o $@ $<

transfer: all
	../../transfer.py wozmon.bin 0x1000

loader.bin: appleiimonitor.bin

loader: appleiimonitor.bin loader.bin

mon: appleiimonitor.bin
	../../transfer.py appleiimonitor.bin -s 0x1000

romtest: loader
	../../transfer.py loader.bin -s 0x0400
	
supermon.bin: supermon.a ${ACME}/*.a
	acme -v $(DEFINES) -f plain -l $<.labels --cpu 65c02 -o $@ $<

supermonloader.bin: supermonloader.a ${ACME}/*.a 
	acme -v $(DEFINES) -f plain -l $<.labels --cpu 65c02 -o $@ $<
	
supermonloader: supermon.bin supermonloader.bin

smon: supermonloader.bin
	../../transfer.py supermonloader.bin -s 0x400
    
