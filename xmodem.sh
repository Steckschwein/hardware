#!/bin/bash

port=/dev/ttyUSB0
speed=115200


while [ "$1" != "" ] ; do
    case $1 in
        -d)
        shift
        port=$1
        ;;
        -s)
        shift
        speed=$1
        ;;
        *)
        file=$1
        ;;
    esac
    shift
done

stty -F $port $speed ignbrk -brkint -icrnl -imaxbel -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echoke
sx $file > $port < $port
