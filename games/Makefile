all: pacman.bin
clean:
	rm -f *.bin *.labels
	( cd avr-keyboard-interface/software ; make clean )

%.bin: %.a
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py pacman.bin 
