all: 3ddotscroll.bin demo.bin
clean:
	rm -f *.bin *.labels
	
%.bin: %.a ../vdp/*.h.a ../vdp/*.lib.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py demo.bin	0x1000