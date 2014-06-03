MAKEFILE=Makefile
all: build

# include vdp/Makefile


clean:
	(cd bios; make clean)
	(cd memtest; make clean)
	(cd vdp; make clean)
#	(cd charsets; make clean)
	(cd keyboard; make clean)

build:
	(cd bios; make)
	(cd memtest; make)
#	(cd charsets; make)
	(cd vdp; make)
	(cd keyboard; make )

