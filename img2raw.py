#!/usr/bin/python

import sys
import os
from PIL import Image, ImageOps

gamma=1

for filename in sys.argv[1::]:
	print "Processing %s" % filename

	if not os.path.isfile(filename):
		print "\t%s: file not found" % filename
		continue


	outfile  = os.path.basename(filename).split(".")[0] + ".raw"

	with Image.open(filename) as img:
		print "\tSource image is %dx%d" % img.size

		img = ImageOps.fit(img, (256, 192), Image.ANTIALIAS)
		print "\tResized to %dx%d" % img.size

	with open(outfile, "w") as fout:
		fout.write(bytearray([((int(g*gamma) & 0xe0) | ((int(r*gamma) & 0xe0) >> 3) | ((int(b*gamma) & 0xff) >> 6)) for (r,g,b) in list(img.getdata())]))

	print "\tOutput written to %s" % outfile
