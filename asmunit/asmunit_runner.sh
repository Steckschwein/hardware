#!/bin/bash

output=0x0200	# use steckschwein i/o area as default to avoid conflicts. on steckschwein, code are never placed here

if [ -z "$1" ]; then
	echo "usage $0 <file> [address, defaults 0x1000]" >&2
	exit 1;
fi
if [ ! -r "$1" ]; then
	echo "file $1 does not exist or is not accessible!" >&2
	exit 1;
fi
address=$2
if [ -z ${address} ]; then
	address="$1000"
fi
binary=$1
# python => python >=3.x required
python asmunit.monitor.py -m 65c02 --output $output <<EOUNIT
.load "${binary}" ${address}
.goto ${address}
EOUNIT