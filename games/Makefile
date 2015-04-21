all: invaders.bin

clean:
	rm -f *.bin *.labels

%.bin:	%.a ../vdp/*.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py invaders.bin	