all: blocks.bin
clean:
	rm -f *.bin *.labels
blocks.bin:
%.bin: %.asm
	acme -v -f plain --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py tetris.bin	