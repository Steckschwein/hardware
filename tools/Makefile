all: wozmon.bin appleiimonitor.bin

clean:
	rm -f *.bin
	
%.bin: %.a steckschwein.adapter.a
	acme -v -f plain -l $<.labels --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py wozmon.bin 0x1000

mon: appleiimonitor.bin
	../transfer.py appleiimonitor.bin 0x1000