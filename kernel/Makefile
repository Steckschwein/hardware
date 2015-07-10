all:  kernel.bin kernel.h.a
clean:
	rm -f *.bin 

kernel.bin: textui.a gfxui.a
loader.bin: kernel.bin
kernel.h.a: kernel.bin
	grep krn_ kernel.a.labels | sed -e"s/krn_//g" | sort > kernel.h.a.tmp
	cat kernel.h.a.stub kernel.h.a.tmp > ../lib/kernel.h.a
	rm kernel.h.a.tmp
%.bin: %.a
	acme -vv -f plain -Wtype-mismatch -l $<.labels --cpu 65c02 -o $@ $<
transfer: kernel.bin
	../transfer.py kernel.bin 0xd600
