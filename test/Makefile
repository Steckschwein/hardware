all: test.bin
clean:
	rm -f *.bin *.labels

%.bin: %.a
	acme -v -f plain -l $<.labels  --cpu 65c02 -o $@ $<

transfer: all
	../transfer.py test.bin 0x0800
