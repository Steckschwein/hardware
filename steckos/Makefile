MAKEFILE=Makefile
all: build

# include vdp/Makefile


clean:
	(cd kernel; make clean)
	(cd shell; make clean)
	(cd tools; make clean)

build:
	(cd kernel; make )
	(cd shell; make )
	(cd tools; make )
