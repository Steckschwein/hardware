all: bios.bin 
clean:
	rm *.bin

%.bin: %.a
	acme -v -f plain -l $<.labels  --cpu 65c02 -o $@ $<
