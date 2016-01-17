ACME_OPTS=-v1 -f plain --cpu 65c02

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
	grep sys_ bios.a.labels | sed -e"s/sys_/bios_/g" | awk -F' '  '{print "#define " $$2 " " $$4}' | sed -e 's/\$$/0x/g' > bios_jumptable.h
	grep sys_ bios.a.labels | sed -e"s/sys_/bios_/g" | awk -F' '  '{print $$2 " = " $$4}' > bios.inc
	
%.bin: %.a ${ACME}/t9929.h.a ${ACME}/t99xx.lib.a vdp.a 
	acme -vv -Dexperimental=1 -Wtype-mismatch -l $<.labels $(ACME_OPTS) -o $@ $<

burn: bios.bin
	mkfile 24k 24k.bin
	cat bios.bin 24k.bin > burn.bin
	minipro -p AT28C256 -w burn.bin
	rm 24k.bin burn.bin
transfer: loader
	../transfer.py loader.bin 0x0400
