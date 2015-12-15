all:  kernel.bin kernel.h.a loader.bin test.bin
clean:
	rm -f *.bin 

kernel.bin: textui.a gfxui.a ../lib/fat.a
loader.bin: test.bin
loader.bin: kernel.bin
kernel.h.a: kernel.bin
	grep krn_ kernel.a.labels | sed -e"s/krn_//g" | sort > kernel.h.a.tmp
	cat kernel.h.a.stub kernel.h.a.tmp > ../lib/kernel.h.a
	rm kernel.h.a.tmp
%.bin: %.a textui.a
	acme -Dexperimental=1 -f plain -Wtype-mismatch -l $<.labels --cpu 65c02 -o $@ $<
transfer: loader.bin
	../transfer.py loader.bin 0x1000
test: test.bin
	../transfer.py test.bin 0x1000