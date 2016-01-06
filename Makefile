MAKEFILE=Makefile
all: build

# include vdp/Makefile


clean:
	(cd bios; make clean)
	(cd steckos; make clean)
	(cd keyboard; make clean)
build:
	(cd bios; make )
	(cd steckos; make )
	(cd keyboard; make )
