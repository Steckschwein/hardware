#!/bin/bash

dir=`dirname $0`
logfile=$1.log
$dir/asmunit_runner.sh $1 $2 > $logfile

if [ "`grep FAIL $logfile`" != "" ] ; then
        cat $logfile
        exit 1
fi

exit 0
