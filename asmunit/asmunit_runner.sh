#!/bin/bash

pythonbin=`which python3`
if [ -z "${pythonbin}" ];then
	echo "python not found!"
	exit -1
fi
pyversion=$(${pythonbin} --version 2>&1 | cut -d '.' -f1)
if ! [[ ${pyversion} =~ 3.* ]]; then
	echo "${pyversion} detected, 3.x required!"
	exit -1
fi

output=0x0200	# use steckschwein i/o area as default to avoid conflicts. on steckschwein, code are never placed here
dir=`dirname $0`
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
${pythonbin} ${dir}/asmunit.monitor.py -m 65c02 --output $output <<EOUNIT
.load "${binary}" ${address}
.goto ${address}
EOUNIT