ACME_OPTS=-v2 -f plain --cpu 65c02

.PHONY: all
all: bios.bin

.PHONY: clean
clean:
	-rm -f *.bin *.labels bios.h.a

loader: loader.bin
loader.bin: bios.bin

%.bin: %.a 
	acme -Wtype-mismatch $(ACME_OPTS) -o $@ $<

burn: bios.bin
	mkfile 24k 24k.bin
	cat bios.bin 24k.bin > burn.bin
	minipro -p AT28C256 -w burn.bin
	rm 24k.bin burn.bin
transfer: loader
	../../transfer.py -s 0x0400 loader.bin
