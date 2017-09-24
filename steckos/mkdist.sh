#!/bin/bash

TARGET=$1
TOOLS="clear.prg ls.prg ll.prg rename.prg date.prg nvram.prg setdate.prg keycode.prg view.prg"

rm -r dist/*
mkdir -p dist/BIN
cp kernel/loader.bin dist/LOADER.BIN
cp shell/shell.prg dist/SHELL.PRG

for n in $TOOLS ; do
	un=`echo $n | awk '{print toupper($0)}'`
	cp tools/$n dist/BIN/$un
done

#^for i in {0..9} ; do 
#	echo foobar > dist/FILE$i.DAT
#done

cp -a dist/* $TARGET &&  umount $TARGET
