all: pacman.bin
clean:
	rm -f *.bin *.labels
	
%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py pacman.bin 
