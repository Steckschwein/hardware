#!/bin/bash
# 
# xpm output from iconmaker
#
if [ ! -e "$1" ]; then
	echo "nicht so!, datei '$1' not found!"
	exit -1;
fi
tail -n+6 $1 | cut -b 1-17 | tr '! ' '#.' | sed "s/\"/+SpriteLine16 %/g"
