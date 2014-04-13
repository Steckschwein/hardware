all: bios.bin 
clean:
	rm -f *.bin *.labels

%.bin: %.a
	acme -v -f plain -l $<.labels  --cpu 65c02 -o $@ $<
