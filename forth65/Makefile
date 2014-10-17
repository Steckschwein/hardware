all: fig6502.bin
clean:
	rm -f *.bin *.labels

%.bin: %.a
	acme -v -f plain -o $@ $<

transfer: all
	../transfer.py fig6502.bin 0x1000
