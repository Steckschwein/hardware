ACME_OPTS=-v -f plain --initmem 0xFF --cpu 65c02
all: bios.bin bios.h.a 

clean:
	rm -f *.bin *.labels bios.h.a

loader: bios.h.a loader.bin
loader.bin: bios.bin

bios.h.a: bios.bin
%.h.a: %.a
	grep sys_ bios.a.labels | sed -e"s/sys_//g" > $@
   
%.bin: %.a
	acme -l $<.labels $(ACME_OPTS) -o $@ $<

transfer: loader
	../transfer.py loader.bin 0x1000
