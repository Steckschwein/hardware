#!/bin/bash

TARGET=$1
TOOLS="ls.bin date.bin hello.bin uname.bin fibo.bin nvram.bin"

mkdir -p dist/bin
for n in loader.bin shell.bin ; do
	cp kernel/$n dist
done

for n in $TOOLS ; do
	cp tools/$n dist/bin
done

cp -a dist/* $TARGET && diskutil unmount $TARGET
