all: bios.bin 
clean:
	rm *.bin *.labels bios.h.a

%.bin: %.a
	acme -v -f plain -l $<.labels  --cpu 65c02 -o $@ $<
