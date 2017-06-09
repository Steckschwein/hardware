MAKEFILE=Makefile
all: build

clean:
	(cd rom; make clean)
	(cd steckos; make clean)
	(cd firmware; make clean)
	
build:
	(cd rom; make)
	(cd steckos; make)
	(cd firmware; make)

transfer:
#	gcc transfer.c  -o transfer
