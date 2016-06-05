all:  kernel.bin kernel.h.a loader.bin 
clean:
	rm -f *.bin 

kernel.bin: textui.a gfxui.a ../../lib/fat.a
loader.bin: kernel.bin
kernel.h.a: kernel.bin kernel.h.a.stub
	grep krn_ kernel.a.labels | sed -e"s/krn_//g" | sort > kernel.h.a.tmp
	grep krn_ kernel.a.labels | sort >> kernel.h.a.tmp
	cat kernel.h.a.stub kernel.h.a.tmp > ../../lib/kernel.h.a
	rm kernel.h.a.tmp
	grep krn_ kernel.a.labels | awk -F' '  '{print $$2 " = " $$4}' > kernel.inc
	
%.bin: %.a textui.a keyboard.textui.adapter.a
	acme -v2 -Dexperimental=1 -f plain -Wtype-mismatch -l $<.labels --cpu 65c02 -o $@ $<
	
transfer: loader.bin
	../../transfer.py loader.bin -s 0x1000

test: test.bin
	../../transfer.py test.bin 0x1000
