all: fat.bin
clean:
	rm *.bin

%.bin: %.a
	acme -v -f plain  --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py fat.bin 0xc000
