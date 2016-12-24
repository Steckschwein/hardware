MAKEFILE=Makefile
all: build

clean:
	(cd bios; make clean)
	(cd steckos; make clean)
	(cd firmware; make clean)
	rm transfer
build:
	(cd bios; make)
	(cd steckos; make)
	(cd firmware; make)

transfer:
	gcc transfer.c  -o transfer
