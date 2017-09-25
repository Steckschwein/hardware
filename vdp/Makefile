ACMEOPT = -v1 -f plain

all: vdp

clean:
	rm -f *.prg
	
vdp: t9929.bin vramtest.bin gfx_mode2.bin gfx_mode3.bin text_mode.bin libtest.bin raster.bin #gfx_lib_test.bin

# !!! we have to explicitly list the %.h.a dependency, otherwise changes within the .h.a file are not detected by make
%.bin: %.a ${ACME}/t9929.h.a ${ACME}/*.lib.a
	acme ${ACMEOPT} -l $<.labels --cpu 65c02 -o $@ $<

%: %.bin
	../transfer.py $@.bin -s 0x1000