#!/bin/bash

TARGET=$1
TOOLS="clear.prg ls.prg ll.prg date.prg hello.prg uname.prg fibo.prg nvram.prg"

mkdir -p dist/bin
cp kernel/loader.bin dist
cp shell/shell.bin dist

for n in $TOOLS ; do
	cp tools/$n dist/bin
done

cp -a dist/* $TARGET &&  umount $TARGET
