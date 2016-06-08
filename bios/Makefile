ACME_OPTS=-v2 -f plain --cpu 65c02

.PHONY: all
all: bios.bin bios.h.a

.PHONY: clean
clean:
	rm -f *.bin *.labels bios.h.a

loader: loader.bin
loader.bin: bios.bin
bios.bin: ${ACME}/defs.h.a

%.bin: %.a ${ACME}/t9929.h.a ${ACME}/t99xx.lib.a vdp.a 
	acme -Wtype-mismatch -l $<.labels $(ACME_OPTS) -o $@ $<

burn: bios.bin
	mkfile 24k 24k.bin
	cat bios.bin 24k.bin > burn.bin
	minipro -p AT28C256 -w burn.bin
	rm 24k.bin burn.bin
transfer: loader
	../transfer.py -s 0x0400 loader.bin
