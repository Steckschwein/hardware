ACME_OPTS=-v -f plain 
all: bios.bin bios.h.a 

clean:
	rm -f *.bin *.labels bios.h.a

loader: bios.h.a loader.bin
loader.bin: bios.bin

bios.h.a: bios.bin
%.h.a: %.a
	grep sys_ bios.a.labels | sed -e"s/sys_//g" > $@
   
%.bin: %.a ../vdp/*.h.a ../vdp/*.lib.a
	acme -l $<.labels $(ACME_OPTS) -o $@ $<

burn: bios.bin
	minipro -p AT28C256 -w bios.bin -e
transfer: loader
	../transfer.py loader.bin 0x0800
