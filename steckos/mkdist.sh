#!/bin/bash

TARGET=$1
TOOLS="clear.prg ls.prg ll.prg rename.prg date.prg nvram.prg setdate.prg keycode.prg"

rm -r dist/*
mkdir -p dist/BIN
cp kernel/loader.bin dist/LOADER.BIN
cp shell/shell.bin dist/SHELL.BIN

for n in $TOOLS ; do
	un=`echo $n | awk '{print toupper($0)}'`
	cp tools/$n dist/BIN/$un
done

for i in {0..9} ; do 
	dd if=/dev/zero of=dist/FILE000$i.DAT bs=32k count=1 
done

cp -a dist/* $TARGET &&  umount $TARGET
