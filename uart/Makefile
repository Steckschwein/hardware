all: uart
clean:
	rm *.bin

bios: bios.bin
uart: uart.bin
minimal: minimal.bin
minibios: minibios.bin

test: test.bin
memtest: memtest.bin

%.bin: %.a
	acme -v -f plain -l $<.labels  --cpu 65c02 -o $@ $<

transfer: uart.bin
	../transfer.py uart.bin
