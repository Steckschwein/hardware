MAKEFILE=Makefile
DIST_TARGET=/media/dommas/STCKSCHWN/
all: build

clean:
	(cd test; make clean)
	(cd tools; make clean)
	(cd shell; make clean)
	(cd libsrc; make clean)
	(cd kernel; make clean)
	rm -rf dist/*

build:
	(cd kernel; make )
	(cd libsrc; make )
	(cd shell; make )
	(cd tools; make )
	(cd test; make )

dist: build
	./mkdist.sh $(DIST_TARGET)