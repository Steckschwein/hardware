all: memtest.bin test.bin
clean:
	rm *.bin *.labels

%.bin: %.a
	acme -v -f plain -l $<.labels  --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py memtest.bin 0x0200
