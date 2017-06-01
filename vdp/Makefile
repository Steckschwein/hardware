ACMEOPT = -v1 -f plain

all: vdp

clean:
	rm -f *.prg
	
vdp: t9929.bin vramtest.bin gfx_mode2.bin gfx_mode3.bin text_mode.bin libtest.bin raster.bin #gfx_lib_test.bin

# !!! we have to explicitly list the %.h.a dependency, otherwise changes within the .h.a file are not detected by make
%.prg: %.a ${ACME}/t9929.h.a ${ACME}/*.lib.a
	acme ${ACMEOPT} -l $<.labels --cpu 65c02 -o $@ $<

splitscreen: splitscreen.bin
	../transfer.py splitscreen.bin -s 0x1000

raster: raster.bin
	../transfer.py raster.bin -s 0x1000
    
transfer: gfx_mode_mc.prg
#	../transfer.py t9929.bin -s 0x1000
#	../transfer.py vramtest.bin 0x1000
#	../transfer.py libtest.bin 0x1000
#	../transfer.py gfx_mode2.bin -s 0x1000
	../transfer.py gfx_mode_mc.prg -s 0x1000
#	../transfer.py text_mode.bin 0x1000
#	../transfer.py gfx_lib_test.bin -s 0x1000

test: all
	../transfer.py libtest.bin 0x1000   
#
# cl65 --cpu 65c02 --start-addr $1000 --config ../cc65/steckschwein.cfg gfx_lib_test.c -o gfx_lib_test.o
#