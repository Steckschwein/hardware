all: bios
clean:
	rm *.bin

bios: bios.bin

%.bin: %.a
	acme -v -f plain -l $<.labels  --cpu 65c02 -o $@ $<
