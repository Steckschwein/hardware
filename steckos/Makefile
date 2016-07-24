MAKEFILE=Makefile
all: build

# include vdp/Makefile


clean:
	(cd tools; make clean)
	(cd shell; make clean)
	(cd libsrc; make clean)
	(cd kernel; make clean)

build:
	(cd kernel; make )
	(cd libsrc; make )
	(cd shell; make )
	(cd tools; make )
