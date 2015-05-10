ACME_OPTS=-v -f plain

.PHONY: all
all: bios.bin bios.h.a

.PHONY: clean
clean:
	-rm -f *.bin *.labels bios.h.a

loader: bios.h.a loader.bin
loader.bin: bios.bin
bios.bin: ${ACME}/defs.h.a

bios.h.a: bios.bin
	grep sys_ bios.a.labels | sed -e"s/sys_//g" | sort > bios.h.a.tmp
	cat bios.h.a.stub bios.h.a.tmp > ../lib/bios.h.a
	rm bios.h.a.tmp
	
%.bin: %.a ${ACME}/t9929.h.a
	acme -Wtype-mismatch -l $<.labels $(ACME_OPTS) -o $@ $<

burn: bios.bin
	mkfile 24k 24k.bin
	cat bios.bin 24k.bin > burn.bin
	minipro -p AT28C256 -w burn.bin
	rm 24k.bin burn.bin
transfer: loader
	../transfer.py loader.bin 0x0400
