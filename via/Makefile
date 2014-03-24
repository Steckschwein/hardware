all: via.bin
clean:
	rm *.bin *.label

%.bin: %.a
	acme -v -f plain -l $<.labels  --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py via.bin 0x1000
