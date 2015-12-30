all: wozmon.bin appleiimonitor.bin

clean:
	rm -f *.bin
	
%.bin: %.a steckschwein.adapter.a ${ACME}/*.a ../bios/vdp.a
	acme -v -f plain -l $<.labels --cpu 65c02 -o $@ $<

loader: loader.bin

loader.bin: appleiimonitor.bin

transfer: all
	../transfer.py wozmon.bin 0x1000

mon: appleiimonitor.bin
	../transfer.py appleiimonitor.bin 0x1000
    
romtest: loader
	../transfer.py loader.bin 0x0400