all: wozmon.bin

clean:
	rm -f *.bin
	
%.bin: %.a
	acme -v -f plain -l $<.labels --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py wozmon.bin 0x1000