all: pacman.bin invaders.bin 
clean:
	rm -f *.bin *.labels

%.bin: %.a ../vdp/*.lib.a ../vdp/*.h.a *.*.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py invaders.bin	