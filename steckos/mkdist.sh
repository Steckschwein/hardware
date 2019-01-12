#!/bin/bash

TARGET=$1
TOOLS_BIN="clear.prg ls.prg ll.prg stat.prg rename.prg date.prg keycode.prg view.prg rm.prg rmdir.prg mkdir.prg cp.prg pwd.prg touch.prg attrib.prg help.prg wozmon.prg"
TOOLS_SBIN="nvram.prg setdate.prg fsinfo.prg"
TOOLS_USRBIN="ppmview.prg"

rm -fr dist/*
mkdir -p ${TARGET}
mkdir -p dist/BIN
mkdir -p dist/SBIN
mkdir -p dist/USR/BIN
cp kernel/loader.bin dist/LOADER.BIN
cp shell/shell.prg dist/SHELL.PRG

for n in `ls tools/*.prg` ; do
	filename=`basename ${n}`
	un=`echo ${filename} | awk '{print toupper($0)}'`
	cp $n dist/BIN/$un
done

for n in $TOOLS_SBIN ; do
	un=`echo $n | awk '{print toupper($0)}'`
	cp tools/$n dist/SBIN/$un
done

for n in `ls tools/*/*.prg` ; do
	filename=`basename ${n}`
	un=`echo ${filename} | awk '{print toupper($0)}'`
	cp $n dist/USR/BIN/$un
done

cp tools/xmodem/rx.prg dist/BIN/RX.PRG
cp ehbasic/basic.prg dist/USR/BIN/BASIC.PRG
cp imfplayer/imf.prg dist/USR/BIN/IMF.PRG
cp edlib/edlply.prg dist/USR/BIN/EDLPLY.PRG

cp -a dist/* $TARGET && umount $TARGET
