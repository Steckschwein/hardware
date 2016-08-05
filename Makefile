MAKEFILE=Makefile
all: build

clean:
	(cd bios; make clean)
	(cd steckos; make clean)
	(cd firmware; make clean)
build:
	(cd bios; make)
	(cd steckos; make)
	(cd firmware; make)