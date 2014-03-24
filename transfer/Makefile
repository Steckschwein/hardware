all: byte
clean:
	rm *.bin

byte: byte.bin test.bin

%.bin: %.a
	acme -v -f plain -l $<.labels  --cpu 65c02 -o $@ $<

transfer: byte.bin
	../transfer.py byte.bin
