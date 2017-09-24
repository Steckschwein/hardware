#!/bin/bash

TARGET=$1
TOOLS_BIN="clear.prg ls.prg ll.prg rename.prg date.prg keycode.prg view.prg rmdir.prg mkdir.prg"
TOOLS_SBIN="nvram.prg setdate.prg"
TOOLS_USRBIN="view.prg"

rm -r dist/*
mkdir -p dist/BIN
mkdir -p dist/SBIN
mkdir -p dist/USR/BIN
cp kernel/loader.bin dist/LOADER.BIN
cp shell/shell.prg dist/SHELL.PRG

for n in $TOOLS_BIN ; do
	un=`echo $n | awk '{print toupper($0)}'`
	cp tools/$n dist/BIN/$un
done

for n in $TOOLS_SBIN ; do
	un=`echo $n | awk '{print toupper($0)}'`
	cp tools/$n dist/SBIN/$un
done

for n in $TOOLS_USRBIN ; do
	un=`echo $n | awk '{print toupper($0)}'`
	cp tools/$n dist/USR/BIN/$un
done

cp tools/xmodem/rx.prg dist/BIN/RX.PRG
cp ehbasic/basic.prg dist/USR/BIN/BASIC.PRG

cp -a dist/* $TARGET &&  umount $TARGET
