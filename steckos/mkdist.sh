#!/bin/bash

TARGET=$1
TOOLS="clear.prg ls.prg ll.prg date.prg nvram.prg setdate.prg"

mkdir -p dist/bin
cp kernel/loader.bin dist
cp shell/shell.bin dist

for n in $TOOLS ; do
	cp tools/$n dist/bin
done

cp -a dist/* $TARGET &&  umount $TARGET
